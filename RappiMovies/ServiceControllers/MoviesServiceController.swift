import Foundation
import PromiseKit

typealias MovieResultsInfo = (TMDBConfiguration, PaginatedResult<[(MovieAbstract,MediaImagesInfo)]>)

protocol MoviesServiceControllerListener: AnyObject {
    func didFinishFetchingMovies(fromCategory category: MovieCategory,
                                 page:Int,
                                 results:Result<MovieResultsInfo>)
}

final class MoviesServiceController: ServiceController {
    let configurationService: TMDBConfigurationService
    let moviesService: MoviesService
    let imagesInfoService: MovieImagesInfoService
    private var listeners: [MoviesServiceControllerListener] = []
    
    func fetchMoviePage(_ page: Int, of category: MovieCategory, ignoringPersistance: Bool = false) {
        configurationService.fetchConfiguration(ignoringPersistance: ignoringPersistance).then { configuration in
            return self.moviesService.fetchMoviePage(page, of: category).then { paginatedMoviesResult -> Promise<MovieResultsInfo> in
                let imagesInfoPromises = paginatedMoviesResult.results.map { movie in
                    self.imagesInfoService.fetchImagesInfoForMovieId(movie.id)
                }
                return when(fulfilled: imagesInfoPromises).map { imagesInfos -> MovieResultsInfo in
                    let moviesWithImagesInfo = zip(paginatedMoviesResult.results, imagesInfos).map { ($0,$1) }
                    let paginationInfo = paginatedMoviesResult.paginationInfo
                    let newPaginatedResult = PaginatedResult(results: moviesWithImagesInfo, paginationInfo: paginationInfo)
                    return (configuration, newPaginatedResult)
                }
            }
        }.done { movieResultsInfo in
            self.listeners.forEach { listener in
                listener.didFinishFetchingMovies(fromCategory: category, page: page, results: Result.Success(movieResultsInfo))
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
    
    init(configurationService: TMDBConfigurationService, moviesService: MoviesService, imagesInfoService: MovieImagesInfoService) {
        self.configurationService = configurationService
        self.moviesService = moviesService
        self.imagesInfoService = imagesInfoService
    }
}
