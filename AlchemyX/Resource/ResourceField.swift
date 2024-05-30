public struct ResourceField: Identifiable {
    public var id: String { name }
    public let name: String
    public let type: String

    public init(_ name: String, type: String) {
        self.name = name
        self.type = type
    }
}
