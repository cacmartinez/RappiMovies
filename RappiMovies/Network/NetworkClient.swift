import Foundation

enum Response<Object> {
    case Success(Object)
    case Error(Error)
}

protocol NetworkClient {
    func get<T: Decodable>(url: URL, callback: @escaping (Response<T>)->())
}
