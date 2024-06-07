import Foundation
import Papyrus

private let tokenKey = "alchemy_auth_token"

public final class AuthClient {
    private let provider = HTTPClient().provider
    private var api: AuthAPI {
        AuthAPIAPI(provider: provider)
    }

    @MainActor
    var token: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set { UserDefaults.standard.setValue(newValue, forKey: tokenKey) }
    }

    public init() {}

    public func signin(email: String, password: String) async throws {
        let res = try await api.signIn(email: email, password: password)
        await updateToken(res.token)
    }

    public func signup(email: String, password: String) async throws {
        let res = try await api.signIn(email: email, password: password)
        await updateToken(res.token)
    }

    public func signout() async throws {
        try await api.signOut()
        await updateToken(nil)
    }

    @discardableResult
    public func getUser() async throws -> User {
        try await api.getUser()
    }

    public func updateUser(
        email: String? = nil,
        phone: String? = nil,
        password: String? = nil
    ) async throws -> User {
        try await api.updateUser(email: email, phone: phone, password: password)
    }

    @MainActor
    private func updateToken(_ token: String?) {
        self.token = token
    }
}
