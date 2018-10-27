import Foundation

struct TMDBURLProvider: TMDBURLProviderProtocol {
    private let apiVersion: Int
    private let baseURL: String
    private let baseQueryParameters: [String: String]
    
    init(baseURL: String, version: Int, apiKey: String) {
        self.apiVersion = version
        self.baseURL = baseURL
        baseQueryParameters = [
            "api_key": apiKey
        ]
    }
    
    func url(for endpoint: TMDBEndpoint) -> URL {
        var queryDictionary = baseQueryParameters
        endpoint.queryParameters.forEach { key, value in
            guard queryDictionary[key] == nil else { fatalError("Repeated parameter \(key) is not allowed") }
            queryDictionary[key] = value
        }
        var query = queryDictionary.lazy.map { key, value in
            "\(key)=\(value)"
        }.joined(separator: "&")
        query = query.isEmpty ? "" : "?\(query)"
        return URL(string: "\(baseURL)/\(apiVersion)\(endpoint.path)\(query)")!
    }
}
