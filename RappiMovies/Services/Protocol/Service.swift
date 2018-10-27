import Foundation

protocol Service {
    associatedtype Listener
    
    func addListener(listener: Listener)
    func removeListener(listener: Listener)
}
