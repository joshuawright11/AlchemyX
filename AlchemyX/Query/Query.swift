#if canImport(SwiftUI)

import Combine
import SwiftUI

@propertyWrapper
public struct Query<R: Resource>: DynamicProperty {
    final class Storage: ObservableObject {
        
        @Published var isLoading: Bool = false
        @Published var error: Error? = nil
        @Published var results: [R]? = nil

        var parameters: QueryParameters
        var cancellables = Set<AnyCancellable>()
        
        init(parameters: QueryParameters = .init(filters: [], sorts: [])) {
            self.parameters = parameters
        }

        func observe() {
            Task { [weak self] in
                for await _ in EventStream.monitorResource(R.self) {
                    self?._refresh()
                }
            }

            _refresh()
        }

        func get() async throws -> [R] {
            try await ResourceClient<R>().all(parameters)
        }

        @MainActor
        func refresh() async {
            error = nil
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

    @StateObject private var storage = Storage()

    var initialStorage = Storage()

    // MARK: @propertyWrapper

    public var wrappedValue: [R] { storage.results ?? [] }
    public var projectedValue: Query<R> { self }

    // MARK: Underlying

    public var isLoading: Bool { storage.isLoading }
    public var error: Error? { storage.error }
    private var builder: ((Query<R>) -> Query<R>)? = nil

    public init() {
        let storage = Storage()
        storage.observe()
        self._storage = .init(wrappedValue: storage)
    }

    public init(_ builder: @escaping (Query<R>) -> Query<R>) {
        let proxy = builder(Query())
        let storage = Storage(parameters: proxy.initialStorage.parameters)
        storage.observe()
        self._storage = .init(wrappedValue: storage)
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

#endif
