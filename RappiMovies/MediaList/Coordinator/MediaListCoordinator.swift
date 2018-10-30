import Foundation

class MediaListCoordinator: Coordinator {
    let presenter: CoordinatorPresenter
    let appContext: AppContext
    let controllerTitle = "Movies"
    
    func start() {
        let viewController = MediaListViewController()
        viewController.title = controllerTitle
        presenter.present(controller: viewController, animated: false)
    }
    
    init(presenter: CoordinatorPresenter, context: AppContext) {
        self.presenter = presenter
        self.appContext = context
    }
}
