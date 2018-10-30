import UIKit

protocol CoordinatorPresenter {
    func present(controller: UIViewController, animated: Bool)
}

extension UINavigationController: CoordinatorPresenter {
    func present(controller: UIViewController, animated: Bool = true) {
        self.pushViewController(controller, animated: animated)
    }
}
