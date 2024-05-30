public struct QueryParameters: Codable {
    public struct Filter: Codable {
        enum Operator: String, Codable {
            case equals
            case notEquals
            case greaterThan
            case greaterThanEquals
            case lessThan
            case lessThanEquals
        }

        let field: String
        let op: Operator
        let value: String
    }

    public struct Sort: Codable {
        let field: String
        let ascending: Bool
    }

    public var filters: [Filter]
    public var sorts: [Sort]
}
