import Foundation

extension AlchemyClient {
    final class Auth {
        private struct AuthResponse: Codable {
            let token: String
            let user: User
        }

        public let http = HTTPClient()

        @MainActor
        var token: String? {
            get { UserDefaults.standard.string(forKey: "alchemy_auth_token") }
            set { UserDefaults.standard.setValue(newValue, forKey: "alchemy_auth_token") }
        }

        var user: User? = nil

        public func signin(username: String, password: String) async throws {
            let res = try await http.request(.post, "/signin", body: [
                "username": username,
                "password": password
            ], decode: AuthResponse.self)
            await updateToken(res.token)
        }

        public func signup(username: String, password: String) async throws {
            let res = try await http.request(.post, "/signup", body: [
                "username": username,
                "password": password
            ], decode: AuthResponse.self)
            await updateToken(res.token)
        }

        public func signout() async throws {
            await updateToken(nil)
        }

        @MainActor
        private func updateToken(_ token: String?) {
            self.token = token
        }
    }
}
