#if canImport(SwiftUI)

import Papyrus

public final class ResourceClient<R: Resource> {
    let http = HTTPClient()

    public func get(id: R.Identifier) async throws -> R {
        try await http.request(.get, "\(R.path)/\(id)")
    }

    public func all(_ parameters: QueryParameters? = nil) async throws -> [R] {
        try await http.request(.post, "\(R.path)/", body: parameters)
    }

    public func create(_ model: R) async throws -> R {
        try await notifyChange {
            try await http.request(.post, "\(R.path)/create", body: model)
        }
    }

    public func update(_ model: R) async throws -> R {
        guard let id = model.id else { throw ResourceError.missingId }
        return try await notifyChange {
            try await http.request(.patch, "\(R.path)/\(id)")
        }
    }

    public func delete(_ model: R) async throws {
        guard let id = model.id else { throw ResourceError.missingId }
        try await notifyChange {
            try await http.requestData(.delete, "\(R.path)/\(id)")
        }
    }

    @discardableResult
    private func notifyChange<Return>(action: () async throws -> Return) async throws -> Return {
        let value = try await action()
        await EventStream.fire(.resourceChanged(R.self))
        return value
    }
}

#endif
