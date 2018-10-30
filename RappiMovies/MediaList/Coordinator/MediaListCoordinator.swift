import Foundation

class MediaListCoordinator: Coordinator {
    let presenter: CoordinatorPresenter
    let appContext: AppContext
    let category: MovieCategory = .Popular
    
    func start() {
        let controller = MovieListController(moviesService: appContext.moviesService, category: category, dateFormatter: appContext.dateFormatter, configurationController: appContext.configurationController)
        let viewController = MediaListViewController(controller: controller)
        viewController.title = category.rawValue
        presenter.present(controller: viewController, animated: false)
    }
    
    init(presenter: CoordinatorPresenter, context: AppContext) {
        self.presenter = presenter
        self.appContext = context
    }
}
