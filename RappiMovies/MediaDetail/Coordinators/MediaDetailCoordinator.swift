import UIKit

class MediaDetailCoordinator: Coordinator {
    let presenter: CoordinatorPresenter
    let appContext: AppContext
    let detailController: ListController
    let title: String
    
    func start() {
        let viewController: UIViewController = MediaDetailViewController(detailController: detailController)
        viewController.title = title
        presenter.present(controller: viewController, animated: true)
    }
    
    init(presenter: CoordinatorPresenter,
         context: AppContext,
         detailController: ListController,
         title: String) {
        self.presenter = presenter
        self.appContext = context
        self.detailController = detailController
        self.title = title
    }
}
