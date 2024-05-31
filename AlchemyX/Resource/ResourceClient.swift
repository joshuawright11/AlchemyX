import Foundation

public final class ResourceClient<R: Resource> {
    public let basePath: String = [AlchemyX.config.baseURL, R.path].joined(separator: "/")
    public let session: URLSession = .shared
    public let decoder = JSONDecoder()
    public let encoder = JSONEncoder()

    public func get(id: R.Identifier) async throws -> R {
        try await request("GET", "/\(id)")
    }

    public func all(_ parameters: QueryParameters? = nil) async throws -> [R] {
        try await request("POST", "/", body: parameters)
    }

    public func create(_ model: R) async throws -> R {
        try await notifyChange { try await request("POST", "/create", body: model) }
    }

    public func update(_ model: R) async throws -> R {
        guard let id = model.id else { throw ResourceError.missingId }
        return try await notifyChange { try await request("PATCH", "/\(id)") }
    }

    public func delete(_ model: R) async throws {
        guard let id = model.id else { throw ResourceError.missingId }
        try await notifyChange { _ = try await requestData("DELETE", "/\(id)") }
    }

    private func notifyChange<Return>(action: () async throws -> Return) async throws -> Return {
        let value = try await action()
        await ResourceChanges.fire(R.self)
        return value
    }

    private func request<RequestBody: Encodable, ResponseBody: Decodable>(
        _ method: String,
        _ path: String,
        body: RequestBody
    ) async throws -> ResponseBody {
        let body = try encoder.encode(body)
        return try await request(method, path, bodyData: body)
    }

    private func request<ResponseBody: Decodable>(
        _ method: String,
        _ path: String, 
        bodyData: Data? = nil
    ) async throws -> ResponseBody {
        guard let data = try await requestData(method, path, bodyData: bodyData) else {
            throw ResourceError.invalidResponse
        }

        return try decoder.decode(ResponseBody.self, from: data)
    }

    @discardableResult
    private func requestData(_ method: String, _ path: String, bodyData: Data? = nil) async throws -> Data? {
        let url = URL(string: basePath + path)!
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.httpBody = bodyData
        if bodyData != nil {
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, _) = try await session.data(for: req)
        return data
    }
}
