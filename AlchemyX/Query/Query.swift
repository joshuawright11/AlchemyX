import SwiftUI
import Combine

@propertyWrapper
public struct Query<R: Resource>: DynamicProperty {
    final class Storage: ObservableObject {
        @Published var isLoading: Bool = false
        @Published var error: Error? = nil
        @Published var results: [R]? = nil
        @Published var parameters = QueryParameters(filters: [], sorts: [])

        var cancellables = Set<AnyCancellable>()

        init() {
            ResourceChanges
                .monitor(R.self)
                .sink { [weak self] in
                    self?._refresh()
                }
                .store(in: &cancellables)
        }

        func get() async throws -> [R] {
            try await ResourceClient<R>().all(parameters)
        }

        @MainActor
        func refresh() async {
            isLoading = true
            defer { isLoading = false }
            do {
                results = try await get()
            } catch {
                self.error = error
            }
        }

        func _refresh() {
            Task {
                await refresh()
            }
        }
    }

    @StateObject var storage = Storage()

    // MARK: @propertyWrapper

    public var wrappedValue: [R] { storage.results ?? [] }
    public var projectedValue: Query<R> { self }

    // MARK: Underlying

    public var isLoading: Bool { storage.isLoading }
    public var error: Error? { storage.error }

    public init() {}
    public init(_ builder: @escaping (Query<R>) -> Query<R>) {
        self = builder(self)
    }

    // MARK: Actions

    public func get() async throws -> [R] {
        try await storage.get()
    }

    public func refresh() async {
        await storage.refresh()
    }
}

extension Resource {
    public static func query() -> Query<Self> {
        Query()
    }
}
