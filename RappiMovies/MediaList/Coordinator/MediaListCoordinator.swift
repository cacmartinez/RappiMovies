import Foundation

class MediaListCoordinator: Coordinator {
    let presenter: CoordinatorPresenter
    let appContext: AppContext
    let category: MovieCategory = .Popular
    
    func start() {
        let controller = MovieListController(moviesServiceController: appContext.moviesServiceController, category: category, dateFormatter: appContext.dateFormatter)
        let viewController = MediaListViewController(controller: controller)
        viewController.title = category.rawValue
        presenter.present(controller: viewController, animated: false)
    }
    
    init(presenter: CoordinatorPresenter, context: AppContext) {
        self.presenter = presenter
        self.appContext = context
    }
}
