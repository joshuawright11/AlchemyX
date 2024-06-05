public final class AlchemyClient {
    public struct Configuration {
        public var baseURL: String

        public init(baseURL: String) {
            self.baseURL = baseURL
        }
    }

    public static let shared = AlchemyClient()

    private(set) var configuration: Configuration?

    public func configure(baseURL: String) {
        configure(.init(baseURL: baseURL))
    }

    public func configure(_ configuration: Configuration) {
        self.configuration = configuration
    }

    // MARK: Auth

    public var auth = AuthClient()

    // MARK: Storage
}
