import Foundation
import PromiseKit

typealias MovieResultsInfo = (TMDBConfiguration, PaginatedResult<[(MovieAbstract,MediaImagesInfo)]>)

protocol MoviesServiceControllerListener: AnyObject {
    func didFinishFetchingMovies(fromCategory category: MovieCategory,
                                 page:Int,
                                 results:Result<MovieResultsInfo>)
    func moviesServiceControllerDidStartLoadingMovies()
    func moviesServiceControllerDidFinishLoadingMovies()
}

final class MoviesServiceController: ServiceController {
    let configurationService: TMDBConfigurationService
    let moviesService: MoviesService
    let imagesInfoService: MovieImagesInfoService
    private var listeners: [MoviesServiceControllerListener] = []
    
    func fetchMoviePage(_ page: Int, of category: MovieCategory, ignoringPersistance: Bool = false, optimisticDimensions: Bool = false) {
        self.listeners.forEach { $0.moviesServiceControllerDidStartLoadingMovies() }
        configurationService.fetchConfiguration(ignoringPersistance: ignoringPersistance).then { configuration in
            return self.moviesService.fetchMoviePage(page, of: category).then { paginatedMoviesResult -> Promise<MovieResultsInfo> in
                let imagesInfoPromises = paginatedMoviesResult.results.map { movie in
                    self.imagesInfoService.fetchImagesInfoForMovieId(movie.id)
                }
                if optimisticDimensions { // Used only to reduce number of requests on first screen, as we will only use the first size dimension.
                    return imagesInfoPromises[0].map { imagesInfo -> MovieResultsInfo in
                        let moviesWithImagesInfo = paginatedMoviesResult.results.map { ($0, imagesInfo) }
                        let paginationInfo = paginatedMoviesResult.paginationInfo
                        let newPaginatedResult = PaginatedResult(results: moviesWithImagesInfo, paginationInfo: paginationInfo)
                        return (configuration, newPaginatedResult)
                    }
                }
                return when(fulfilled: imagesInfoPromises).map { imagesInfos -> MovieResultsInfo in
                    let moviesWithImagesInfo = zip(paginatedMoviesResult.results, imagesInfos).map { ($0,$1) }
                    let paginationInfo = paginatedMoviesResult.paginationInfo
                    let newPaginatedResult = PaginatedResult(results: moviesWithImagesInfo, paginationInfo: paginationInfo)
                    return (configuration, newPaginatedResult)
                }
            }
        }.ensure {
            self.listeners.forEach { $0.moviesServiceControllerDidFinishLoadingMovies() }
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
