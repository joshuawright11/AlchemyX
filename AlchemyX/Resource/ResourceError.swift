public enum ResourceError: Error {
    case missingId
    case invalidResponse
    case invalidURL(String)
}
