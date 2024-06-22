#if canImport(SwiftUI)

extension Query {
    public func sort<L: LosslessStringConvertible>(_ key: KeyPath<R, L>, ascending: Bool = true) -> Self {
        guard let field = R.fields[key] else {
            preconditionFailure("unable to find field \(key) of type \(L.self) on resource \(R.self)")
        }

        let sort = QueryParameters.Sort(field: field.name, ascending: ascending)
        initialStorage.parameters.sorts.append(sort)
        return self
    }
}

#endif
