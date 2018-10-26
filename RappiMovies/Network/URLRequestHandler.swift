import Foundation

protocol URLRequestHandler {
    func handle(_ request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}

extension URLSession: URLRequestHandler {
    func handle(_ request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        self.dataTask(with: request, completionHandler: completionHandler).resume()
    }
}
