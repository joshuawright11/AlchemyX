import Foundation

struct HTTPClient {
    enum Method: String {
        case post = "POST"
        case get = "GET"
        case patch = "PATCH"
        case put = "PUT"
        case delete = "DELETE"
    }

    let session: URLSession = .shared
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    var alchemy: AlchemyClient {
        .current
    }

    var baseURL: String {
        guard let configuration = alchemy.configuration else {
            preconditionFailure("Alchemy client must be initialized before calling")
        }

        return configuration.baseURL
    }

    func request<RequestBody: Encodable, ResponseBody: Decodable>(
        _ method: Method,
        _ path: String,
        body: RequestBody,
        decode: ResponseBody.Type = ResponseBody.self
    ) async throws -> ResponseBody {
        let body = try encoder.encode(body)
        return try await request(method, path, bodyData: body, decode: decode)
    }

    func request<ResponseBody: Decodable>(
        _ method: Method,
        _ path: String,
        bodyData: Data? = nil,
        decode: ResponseBody.Type = ResponseBody.self
    ) async throws -> ResponseBody {
        guard let data = try await requestData(method, path, bodyData: bodyData) else {
            throw ResourceError.invalidResponse
        }

        return try decoder.decode(decode, from: data)
    }

    @discardableResult
    func requestData(_ method: Method, _ path: String, bodyData: Data? = nil) async throws -> Data? {
        let url = URL(string: baseURL + path)!
        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        req.httpBody = bodyData
        if let token = await alchemy.auth.token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if bodyData != nil {
            req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        let (data, _) = try await session.data(for: req)
        return data
    }
}
