import Combine
import SwiftUI

@propertyWrapper
public struct Auth: DynamicProperty {
    final class Storage: ObservableObject {
        @Published var isLoading: Bool = false
        @Published var error: Error? = nil
        @Published var user: User? = nil

        var cancellables = Set<AnyCancellable>()

        func observe() {
            Task { [weak self] in
                for await _ in EventStream.monitorAuth() {
                    self?._refresh()
                }
            }

            _refresh()
        }

        func get() async throws -> User {
            try await AuthClient().getUser()
        }

        @MainActor
        func refresh() async {
            error = nil
            isLoading = true
            defer { isLoading = false }
            do {
                user = try await get()
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

    public var wrappedValue: User? { storage.user }
    public var projectedValue: Auth { self }

    // MARK: Underlying

    public var isLoading: Bool { storage.isLoading }
    public var error: Error? { storage.error }

    public init() {
        let storage = Storage()
        storage.observe()
        self._storage = .init(wrappedValue: storage)
    }

    // MARK: Actions

    public func get() async throws -> User {
        try await storage.get()
    }

    public func refresh() async {
        await storage.refresh()
    }
}
