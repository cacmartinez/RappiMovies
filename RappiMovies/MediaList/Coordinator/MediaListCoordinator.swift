import Foundation

class MediaListCoordinator: Coordinator {
    let presenter: CoordinatorPresenter
    let appContext: AppContext
    let listTitle: String
    let controller: ListController
    var childCoordinator: Coordinator?
    
    func start() {
        let viewController = ListViewController(controller: controller, delegate: self)
        viewController.title = listTitle
        presenter.present(controller: viewController, animated: true)
    }
    
    init(presenter: CoordinatorPresenter,
         context: AppContext,
         controller: ListController,
         listTitle: String) {
        self.presenter = presenter
        self.appContext = context
        self.listTitle = listTitle
        self.controller = controller
    }
}

extension MediaListCoordinator: ListViewControllerDelegate {
    func didSelectListModel(_ model: ListModel) {
        guard let mediaModel = model as? MediaListModel else {
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
