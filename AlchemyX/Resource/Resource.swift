public protocol Resource: Codable, Identifiable where ID == Identifier? {
    associatedtype Identifier

    var id: Identifier? { get }

    static var path: String { get }
    static var fields: [PartialKeyPath<Self>: ResourceField] { get }
}

extension Resource {
    public static var path: String { 
        "\(Self.self)".lowercased()
    }

    @discardableResult
    public func save() async throws -> Self {
        try await ResourceClient().create(self)
    }

    public func get(id: Identifier) async throws -> Self {
        try await ResourceClient().get(id: id)
    }

    public func all() async throws -> [Self] {
        try await ResourceClient().all()
    }

    @discardableResult
    public func update() async throws -> Self {
        try await ResourceClient().update(self)
    }

    public func delete() async throws {
        try await ResourceClient().delete(self)
    }
}
