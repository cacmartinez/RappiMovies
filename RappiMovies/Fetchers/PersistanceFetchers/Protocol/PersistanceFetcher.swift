import Foundation

protocol PersistanceFetcher {
    associatedtype Model
    
    func clean()
    
}
