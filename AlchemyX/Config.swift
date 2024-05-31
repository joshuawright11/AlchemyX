enum AlchemyX {
    struct Config {
        var baseURL: String = "http://localhost:3000"
    }

    private(set) static var config: Config = .init()

    static func configure(baseURL: String) {
        self.configure(config: .init(baseURL: baseURL))
    }

    static func configure(config: Config) {
        self.config = config
    }
}
