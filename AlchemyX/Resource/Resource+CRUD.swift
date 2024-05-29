import Foundation

extension Resource {
    public func create() async throws -> Self {
        try await ResourceClient().create(self)
    }

    public func get(id: Identifier) async throws -> Self {
        try await ResourceClient().get(id: id)
    }

    public func all() async throws -> [Self] {
        try await ResourceClient().all()
    }

    public func update() async throws -> Self {
        try await ResourceClient().update(self)
    }

    public func delete() async throws {
        try await ResourceClient().delete(self)
    }
}

public struct ResourceClient<R: Resource> {
    public let basePath: String = [ResourceConfig.baseURL, R.path].joined(separator: "/")
    public let session: URLSession = .shared
    public let decoder = JSONDecoder()
    public let encoder = JSONEncoder()

    public func create(_ model: R) async throws -> R {
        try await request("POST", "/", body: model)
    }

    public func get(id: R.Identifier) async throws -> R {
        try await request("GET", "/\(id)")
    }

    public func update(_ model: R) async throws -> R {
        guard let id = model.id else { throw ResourceError.missingId }
        return try await request("PATCH", "/\(id)")
    }

    public func delete(_ model: R) async throws {
        guard let id = model.id else { throw ResourceError.missingId }
        try await request("DELETE", "/\(id)")
    }

    public func all() async throws -> [R] {
        try await request("GET", "/")
    }

    private func request<RequestBody: Encodable, ResponseBody: Decodable>(
        _ method: String,
        _ path: String,
        body: RequestBody
    ) async throws -> ResponseBody {
        let body = try encoder.encode(body)
        return try await request(method, path, body: body)
    }

    private func request<ResponseBody: Decodable>(_ method: String, _ path: String, body: Data? = nil) async throws -> ResponseBody {
        guard let data = try await request(method, path, body: body) else {
            throw ResourceError.invalidResponse
        }

        return try decoder.decode(ResponseBody.self, from: data)
    }

    @discardableResult
    private func request(_ method: String, _ path: String, body: Data? = nil) async throws -> Data? {
        let url = URL(string: basePath + path)!
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.httpBody = body
        if body != nil {
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, _) = try await session.data(for: req)
        return data
    }
}
