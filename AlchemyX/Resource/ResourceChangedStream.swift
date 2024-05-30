import Combine

final class ResourceChanges {
    static let shared = ResourceChanges()

    @Published private var didChangeType = ObjectIdentifier(Void.self)

    @MainActor
    static func fire(_ type: (some Resource).Type) {
        shared.didChangeType = ObjectIdentifier(type)
    }

    static func monitor(_ type: (some Resource).Type) -> AnyPublisher<Void, Never> {
        shared.$didChangeType
            .filter { $0 == ObjectIdentifier(type) }
            .map { _ in }
            .eraseToAnyPublisher()
    }
}
