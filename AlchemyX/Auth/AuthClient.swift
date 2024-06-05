import Foundation
import Papyrus

public final class AuthClient {
    private let provider = HTTPClient().provider
    private var api: AuthAPI {
        AuthAPIAPI(provider: provider)
    }

    @MainActor
    var token: String? {
        get { UserDefaults.standard.string(forKey: "alchemy_auth_token") }
        set { UserDefaults.standard.setValue(newValue, forKey: "alchemy_auth_token") }
    }

    @MainActor
    var user: User? = nil

    public func signin(email: String, password: String) async throws {
        let res = try await api.signIn(email: email, password: password)
        await updateToken(res.token)
        await updateUser(res.user)
    }

    public func signup(email: String, password: String) async throws {
        let res = try await api.signIn(email: email, password: password)
        await updateToken(res.token)
        await updateUser(res.user)
    }

    public func signout() async throws {
        try await api.signOut()
        await updateToken(nil)
        await updateUser(nil)
    }

    @discardableResult
    public func refreshUser() async throws -> User {
        let res = try await api.getUser()
        await updateUser(res)
        return res
    }

    public func updateUser(
        email: String? = nil,
        phone: String? = nil,
        password: String? = nil
    ) async throws {
        let res = try await api.updateUser(email: email, phone: phone, password: password)
        await updateUser(res)
    }

    @MainActor
    private func updateToken(_ token: String?) {
        self.token = token
    }

    @MainActor
    private func updateUser(_ user: User?) {
        self.user = user
    }
}
