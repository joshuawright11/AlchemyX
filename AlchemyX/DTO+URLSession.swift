#if os(iOS) || os(watchOS) || os(tvOS)

import Foundation

// Client side functions
extension Resource {
    public func create() async throws -> Self {
        // 0. POST `name`/
        let route = "\(Config.baseURL)\(Self.self)".lowercased()

        // 1. Params
        let session = URLSession.shared
        let url = URL(string: route)!

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        req.httpBody = try encoder.encode(self)

        // 2. Request
        let (data, _) = try await session.data(for: req)

        // 3. Return
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }

    public func get() async throws -> Self {
        guard let id else {
            throw ResourceError.missingId
        }

        // 0. PATCH `name`/
        let route = "\(Config.baseURL)\(Self.self)/\(id)".lowercased()

        // 1. Params
        let session = URLSession.shared
        let url = URL(string: route)!

        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        // 2. Request
        let (data, _) = try await session.data(for: req)

        // 3. Return
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }

    public func update(_ name: String? = nil, isDone: Bool? = nil) async throws -> Self {
        guard let id else {
            throw ResourceError.missingId
        }

        // 0. PATCH `name`/
        let route = "\(Config.baseURL)\(Self.self)/\(id)".lowercased()

        // 1. Params
        let session = URLSession.shared
        let url = URL(string: route)!

        var req = URLRequest(url: url)
        req.httpMethod = "PATCH"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")


        var dict: [String: AnyEncodable] = [:]
        if let name { dict["name"] = AnyEncodable(name) }
        if let isDone { dict["isDone"] = AnyEncodable(isDone) }
        let encoder = JSONEncoder()
        req.httpBody = try encoder.encode(dict)

        // 2. Request
        let (data, _) = try await session.data(for: req)

        // 3. Return
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }

    public func delete() async throws {
        guard let id else {
            throw ResourceError.missingId
        }

        // 0. DELETE `name`/
        let route = "\(Config.baseURL)\(Self.self)/\(id)".lowercased()

        // 1. Params
        let session = URLSession.shared
        let url = URL(string: route)!

        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"

        let encoder = JSONEncoder()
        req.httpBody = try encoder.encode(self)

        // 2. Request
        let (_, res) = try await session.data(for: req)

        // 3. Status
        guard let res = res as? HTTPURLResponse, (200...299).contains(res.statusCode) else {
            throw ResourceError.invalidResponse
        }
    }

    public static func all() async throws -> [Self] {
        // 0. GET `name`/
        let route = "\(Config.baseURL)\(Self.self)".lowercased()

        // 1. Params
        let session = URLSession.shared
        let url = URL(string: route)!

        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        // 2. Request
        let (data, _) = try await session.data(for: req)

        // 3. Return
        let decoder = JSONDecoder()
        return try decoder.decode([Self].self, from: data)
    }
}

struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    public init<T: Encodable>(_ wrapped: T) {
        _encode = wrapped.encode
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

#endif
