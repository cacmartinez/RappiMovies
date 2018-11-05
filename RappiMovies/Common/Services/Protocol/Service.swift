import Foundation

protocol ServiceController {
    associatedtype Listener
    
    func addListener(listener: Listener)
    func removeListener(listener: Listener)
}
