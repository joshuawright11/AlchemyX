import Foundation
import Papyrus

@API
public protocol AuthAPI {
    @POST("/signin")
    func signIn(email: String, password: String) async throws -> AuthResponse

    @POST("/signup")
    func signUp(email: String, password: String) async throws -> AuthResponse

    @POST("/signout")
    func signOut() async throws

    @GET("/user")
    func getUser() async throws -> User

    @PATCH("/user")
    func updateUser(email: String?, phone: String?, password: String?) async throws -> User
}

public struct AuthResponse: Codable {
    public let token: String
    public let user: User

    public init(token: String, user: User) {
        self.token = token
        self.user = user
    }
}

public struct User: Identifiable, Codable {
    public let id: UUID
    public let email: String?
    public let phone: String?

    public init(id: UUID, email: String?, phone: String?) {
        self.id = id
        self.email = email
        self.phone = phone
    }
}
