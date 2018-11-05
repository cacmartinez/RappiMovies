import UIKit

protocol CoordinatorPresenter {
    func present(controller: UIViewController, animated: Bool)
}

final class ViewControllerPresenter: CoordinatorPresenter {
    private let presentingViewController: UIViewController
    private let wrapsPresentedInNavigation: Bool
    private var navigationController: UINavigationController? = nil
    private var presentedViewController: UIViewController? = nil
    
    init(presentingController: UIViewController, wrapsPresentedInNavigation: Bool) {
        self.presentingViewController = presentingController
        self.wrapsPresentedInNavigation = wrapsPresentedInNavigation
    }
    
    func present(controller: UIViewController, animated: Bool) {
        if let navigationController = navigationController {
            navigationController.present(controller: controller, animated: true)
        } else {
            if let _ = presentedViewController {
                fatalError("present view controller can't be called again when not wrapped in navigation controller")
            }
            presentedViewController = controller
            if wrapsPresentedInNavigation {
                navigationController = UINavigationController(rootViewController: controller)
                controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPresentedViewController))
                presentedViewController = navigationController
            }
            
            presentingViewController.present(presentedViewController!, animated: animated, completion: nil)
        }
    }
    
    @objc func dismissPresentedViewController() {
        guard let presentedController = presentedViewController else { return }
        presentedController.dismiss(animated: true, completion: nil)
    }
}

extension UINavigationController: CoordinatorPresenter {
    func present(controller: UIViewController, animated: Bool = true) {
        self.pushViewController(controller, animated: animated)
    }
}
