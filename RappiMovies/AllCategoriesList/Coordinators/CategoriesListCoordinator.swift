import UIKit

class CategoriesListCoordinator: Coordinator {
    let presenter: CoordinatorPresenter
    let appContext: AppContext
    let controller: ListController
    private var coordinatorViewController: UIViewController!
    private var childCoordinator: Coordinator?
    
    func start() {
        coordinatorViewController = ListViewController(controller: controller, delegate: self)
        coordinatorViewController.title = "Movie Categories"
        presenter.present(controller: coordinatorViewController, animated: false)
    }
    
    init(presenter: CoordinatorPresenter,
         context: AppContext) {
        self.presenter = presenter
        self.appContext = context
        self.controller = CategoriesListController(moviesServiceController: context.moviesServiceController)
    }
}

extension CategoriesListCoordinator: ListViewControllerDelegate {
    func didSelectListModel(_ model: ListModel) {
        childCoordinator = nil
        switch model {
        case let category as MovieCategory:
            let controller = MovieListController(moviesServiceController: appContext.moviesServiceController, category: category, dateFormatter: appContext.dateFormatter)
            childCoordinator = MediaListCoordinator(presenter: presenter,
                                        context: appContext,
                                        controller: controller,
                                        listTitle: category.rawValue)
        case let movie as MovieAbstract:
            let detailController = MovieDetailController(movieId: movie.id, moviesServiceController: appContext.moviesServiceController)
            let presenter = ViewControllerPresenter(presentingController: coordinatorViewController, wrapsPresentedInNavigation: true)
            childCoordinator = MediaDetailCoordinator(presenter: presenter,
                                                      context: appContext,
                                                      detailController: detailController,
                                                      title: movie.title)
            break
        default:
            fatalError("navigation not handled for selected model type")
        }
        childCoordinator?.start()
    }
}
