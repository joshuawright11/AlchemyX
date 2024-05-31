extension Query {
    public func sort<L: LosslessStringConvertible>(_ key: KeyPath<R, L>, ascending: Bool = true) -> Self {
        let field = R.fields[key]!
        let sort = QueryParameters.Sort(field: field.name, ascending: ascending)
        initialStorage.parameters.sorts.append(sort)
        return self
    }
}
