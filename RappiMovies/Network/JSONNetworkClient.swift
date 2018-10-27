import Foundation

struct JSONNetworkClient: NetworkClient {
    private let timeoutInterval = 5.0
    private let dateFormatter: DateFormatter
    private let requestHandler: URLRequestHandler
    
    init(dateFormatter: DateFormatter, requestHandler: URLRequestHandler = URLSession.shared) {
        self.requestHandler = requestHandler
        self.dateFormatter = dateFormatter
    }
    
    func get<T: Decodable>(url: URL, callback: @escaping ResultBlock<T>) {
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeoutInterval)
        requestHandler.handle(request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    callback(Result.Error(error))
                } else {
                    guard let data = data else {
                        fatalError("Received empty data from successful response")
                    }
                    do {
                        let result = try self.decodeJSON(T.self, from:data)
                        callback(Result.Success(result))
                    } catch {
                        fatalError("Error decoding JSON check Decodable objects")
                    }
                }
            }
        }
    }
    
    private func decodeJSON<T: Decodable>(_ objectType:T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return try decoder.decode(objectType, from: data)
    }
}
