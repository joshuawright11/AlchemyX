import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    let email: String?
    let phone: String?
}
