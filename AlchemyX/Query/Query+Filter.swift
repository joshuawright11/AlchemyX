extension Query {
    public func filter(_ filter: (QueryFilter<R>) -> QueryParameters.Filter) -> Self {
        let filter = filter(QueryFilter<R>())
        initialStorage.parameters.filters.append(filter)
        return self
    }
}

@dynamicMemberLookup
public struct QueryFilter<R: Resource> {
    public subscript<L: LosslessStringConvertible>(dynamicMember member: KeyPath<R, L>) -> FilterField<L> {
        FilterField(field: R.fields[member]!.name)
    }

    public subscript(dynamicMember member: KeyPath<R, Bool>) -> QueryParameters.Filter {
        .init(field: R.fields[member]!.name, op: .equals, value: "true")
    }
}

public struct FilterField<L: LosslessStringConvertible> {
    let field: String

    // MARK: Operators

    public static func == (lhs: Self, rhs: L) -> QueryParameters.Filter {
        .init(field: lhs.field, op: .equals, value: rhs.description)
    }

    public static func != (lhs: Self, rhs: L) -> QueryParameters.Filter {
        .init(field: lhs.field, op: .notEquals, value: rhs.description)
    }

    public static func < (lhs: Self, rhs: L) -> QueryParameters.Filter {
        .init(field: lhs.field, op: .lessThan, value: rhs.description)
    }

    public static func > (lhs: Self, rhs: L) -> QueryParameters.Filter {
        .init(field: lhs.field, op: .greaterThan, value: rhs.description)
    }

    public static func <= (lhs: Self, rhs: L) -> QueryParameters.Filter {
        .init(field: lhs.field, op: .lessThanEquals, value: rhs.description)
    }

    public static func >= (lhs: Self, rhs: L) -> QueryParameters.Filter {
        .init(field: lhs.field, op: .greaterThanEquals, value: rhs.description)
    }
}
