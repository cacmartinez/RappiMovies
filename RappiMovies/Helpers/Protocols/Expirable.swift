import Foundation

protocol Expirable {
    var expirationDate: Date { get }
    
    func isExpired() -> Bool
}

protocol ExpirableManagedObject {
    var expirationDate: Date? { get }
    
    func isExpired() -> Bool
}

extension Expirable {
    func isExpired() -> Bool {
        return self.expirationDate < Date()
    }
}

extension ExpirableManagedObject {
    func isExpired() -> Bool {
        guard let expirationDate = expirationDate else { return false }
        return expirationDate < Date()
    }
}
