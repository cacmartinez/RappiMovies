import Foundation

protocol ViewModelActionable {
    var viewModelTapped: (()->Void)? { get set }
}
