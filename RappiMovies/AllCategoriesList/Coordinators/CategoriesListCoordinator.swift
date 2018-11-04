import Foundation

class CategoriesListCoordinator: Coordinator {
    let presenter: CoordinatorPresenter
    let appContext: AppContext
    let controller: MediaListController
    private var childCoordinator: Coordinator?
    
    func start() {
        let viewController = MediaListViewController(controller: controller, delegate: self)
        viewController.title = "Movie Categories"
        presenter.present(controller: viewController, animated: false)
    }
    
    init(presenter: CoordinatorPresenter,
         context: AppContext) {
        self.presenter = presenter
        self.appContext = context
        self.controller = CategoriesListController(moviesServiceController: context.moviesServiceController)
    }
}

extension CategoriesListCoordinator: MediaListViewControllerDelegate {
    func didSelectMedia(_ media: ListModel) {
        childCoordinator = nil
        switch media {
        case let category as MovieCategory:
            let controller = MovieListController(moviesServiceController: appContext.moviesServiceController, category: category, dateFormatter: appContext.dateFormatter)
            childCoordinator = MediaListCoordinator(presenter: presenter,
                                        context: appContext,
                                        controller: controller,
                                        listTitle: category.rawValue)
        case let movie as MovieAbstract:
        // TODO: navigate to movie detail.
            break
        default:
            fatalError("navigation not handled for selected model type")
        }
        childCoordinator?.start()
    }
}
