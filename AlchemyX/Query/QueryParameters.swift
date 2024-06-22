#if canImport(SwiftUI)

public struct QueryParameters: Codable {
    public struct Filter: Codable {
        public enum Operator: String, Codable {
            case contains
            case equals
            case notEquals
            case greaterThan
            case greaterThanEquals
            case lessThan
            case lessThanEquals
        }

        public let field: String
        public let op: Operator
        public let value: String
    }

    public struct Sort: Codable {
        public let field: String
        public let ascending: Bool
    }

    public var filters: [Filter]
    public var sorts: [Sort]
}

#endif
