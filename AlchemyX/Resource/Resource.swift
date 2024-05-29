public protocol Resource: Codable, Identifiable where ID == Identifier? {
    associatedtype Identifier

    var id: Identifier? { get }

    static var path: String { get }
    static var fields: [ResourceField] { get }
}

public extension Resource {
    static var path: String { "\(Self.self)".lowercased() }
}

public struct ResourceField: Identifiable {
    public var id: String { name }
    public let name: String
    public let type: String

    public init(_ name: String, type: String) {
        self.name = name
        self.type = type
    }
}
