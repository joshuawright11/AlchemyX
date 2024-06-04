final class AlchemyClient {
    struct Configuration {
        var baseURL: String
    }

    static let current = AlchemyClient()

    private(set) var configuration: Configuration?

    func configure(baseURL: String) {
        configure(.init(baseURL: baseURL))
    }

    func configure(_ configuration: Configuration) {
        self.configuration = configuration
    }

    // MARK: Auth

    var auth = Auth()

    // MARK: Storage
}

/*
 
 # Auth

 1. login via config
    - server handles username / password
 2. pass bearer token through requests
 3. server filters on token
    - pulls user, filters items of that user
    - need a way to auth / not auth models
        - auto assigns user of authd models

 */
