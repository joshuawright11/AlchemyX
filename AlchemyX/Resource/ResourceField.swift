public struct ResourceField: Identifiable {
    public var id: String { name }
    public let name: String
    public let type: Any.Type

    public init(_ name: String, type: Any.Type) {
        self.name = name
        self.type = type
    }
}
