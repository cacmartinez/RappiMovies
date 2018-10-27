import Foundation

protocol NetworkClient {
    func get<T: Decodable>(url: URL, callback: @escaping ResultBlock<T>)
}
