import Foundation

typealias MovieResultsInfo = (TMDBConfiguration, PaginatedResult<[MovieAbstract]>)

protocol MoviesServiceControllerListener: AnyObject {
    func didFinishFetchingMovies(fromCategory category: MovieCategory,
                                 page:Int,
                                 results:Result<MovieResultsInfo>)
}

final class MoviesServiceController: ServiceController {
    let configurationService: TMDBConfigurationService
    let moviesService: MoviesService
    private var listeners: [MoviesServiceControllerListener] = []
    
    func fetchMoviePage(_ page: Int, of category: MovieCategory, ignoringPersistance: Bool = false) {
        configurationService.fetchConfiguration(ignoringPersistance: ignoringPersistance).then { configuration in
            return self.moviesService.fetchMoviePage(page, of: category).map { paginatedMoviesResult in
                return (configuration, paginatedMoviesResult)
            }
        }.done { configuration, paginatedMoviesResult in
            self.listeners.forEach { listener in
                listener.didFinishFetchingMovies(fromCategory: category, page: page, results: Result.Success((configuration,paginatedMoviesResult)))
            }
        }.catch { error in
            self.listeners.forEach { listener in
                listener.didFinishFetchingMovies(fromCategory: category, page: page, results: Result.Error(error))
            }
        }
    }
    
    func addListener(listener: MoviesServiceControllerListener) {
        if !listeners.contains(where: { $0 === listener }) {
            listeners.append(listener)
        }
    }
    
    func removeListener(listener: MoviesServiceControllerListener) {
        guard let index = listeners.firstIndex(where: { $0 === listener }) else { return }
        listeners.remove(at: index)
    }
    
    init(configurationService: TMDBConfigurationService, moviesService: MoviesService) {
        self.configurationService = configurationService
        self.moviesService = moviesService
    }
}
