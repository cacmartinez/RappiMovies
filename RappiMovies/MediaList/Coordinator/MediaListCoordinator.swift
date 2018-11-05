import Foundation

class MediaListCoordinator: Coordinator {
    let presenter: CoordinatorPresenter
    let appContext: AppContext
    let listTitle: String
    let controller: MediaListController
    var childCoordinator: Coordinator?
    
    func start() {
        let viewController = MediaListViewController(controller: controller, delegate: self)
        viewController.title = listTitle
        presenter.present(controller: viewController, animated: true)
    }
    
    init(presenter: CoordinatorPresenter,
         context: AppContext,
         controller: MediaListController,
         listTitle: String) {
        self.presenter = presenter
        self.appContext = context
        self.listTitle = listTitle
        self.controller = controller
    }
}

extension MediaListCoordinator: MediaListViewControllerDelegate {
    func didSelectMedia(_ media: ListModel) {
        guard let mediaModel = media as? MediaListModel else {
            fatalError("unexpected model sent to coordinator")
        }
        let detailController = MovieDetailController(movieId: mediaModel.id, moviesServiceController: appContext.moviesServiceController)
        childCoordinator = MediaDetailCoordinator(presenter: presenter,
                                                  context: appContext,
                                                  detailController:  detailController,
                                                  title: mediaModel.title)
        childCoordinator?.start()
    }
}
