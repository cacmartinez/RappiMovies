import Foundation
import PromiseKit

struct JSONNetworkClient: NetworkClient {
    private let timeoutInterval = 5.0
    private let dateFormatter: DateFormatter
    private let requestHandler: URLRequestHandler
    
    init(dateFormatter: DateFormatter, requestHandler: URLRequestHandler = URLSession.shared) {
        self.requestHandler = requestHandler
        self.dateFormatter = dateFormatter
    }
    
    func get<T: Decodable>(url: URL) -> Promise<T> {
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeoutInterval)
        return Promise { seal in
            requestHandler.handle(request) { (data, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        seal.resolve(nil, error)
                    } else {
                        guard let data = data else {
                            fatalError("Received empty data from successful response")
                        }
                        do {
                            let result = try self.decodeJSON(T.self, from:data)
                            seal.resolve(result, error)
                        } catch {
                            fatalError("Error decoding JSON check Decodable objects")
                        }
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
