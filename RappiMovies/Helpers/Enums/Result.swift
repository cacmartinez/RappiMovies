import Foundation

typealias ResultBlock<T> = (_ result: Result<T>)->Void

enum Result<Object> {
    case Success(Object)
    case Error(Error)
}
