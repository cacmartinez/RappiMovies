import Foundation
import PromiseKit

protocol NetworkClient {
    func get<T: Decodable>(url: URL) -> Promise<T>
}
