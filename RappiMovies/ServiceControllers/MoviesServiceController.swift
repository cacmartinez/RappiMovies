import Foundation
import PromiseKit

typealias MovieResultsInfo = (TMDBConfiguration, PaginatedResult<[(MovieAbstract,MediaImagesInfo)]>)

protocol MoviesServiceControllerMovieListListener: AnyObject {
    func didFinishFetchingMovies(fromCategory category: MovieCategory,
                                 page:Int,
                                 results:Result<MovieResultsInfo>)
    func moviesServiceControllerDidStartLoadingMovieList()
    func moviesServiceControllerDidFinishLoadingMovieList()
}

protocol MoviesServiceControllerMovieDetailListener: AnyObject {
    func didFinishFetchingMovieDetail(with result: Result<(TMDBConfiguration, MovieDetail)>)
    func moviesServiceControllerDidStartLoadingMovieDetail()
    func moviesServiceControllerDidFinishLoadingMovieDetail()
}

final class MoviesServiceController {
    let configurationService: TMDBConfigurationService
    let moviesService: MoviesService
    let imagesInfoService: MovieImagesInfoService
    private var movieListListeners: [MoviesServiceControllerMovieListListener] = []
    private var movieDetailListeners: [MoviesServiceControllerMovieDetailListener] = []
    
    func fetchMoviePage(_ page: Int, of category: MovieCategory, ignoringPersistance: Bool = false, optimisticDimensions: Bool = false) {
        self.movieListListeners.forEach { $0.moviesServiceControllerDidStartLoadingMovieList() }
        configurationService.fetchConfiguration(ignoringPersistance: ignoringPersistance).then { configuration in
            return self.moviesService.fetchMoviePage(page, of: category).then { paginatedMoviesResult -> Promise<MovieResultsInfo> in
                if optimisticDimensions { // Used only to reduce number of requests on first screen, as we will only use the first size dimension.
                    let fetchImagesInfoForFirstMovie = self.imagesInfoService.fetchImagesInfoForMovieId(paginatedMoviesResult.results[0].id)
                    return fetchImagesInfoForFirstMovie.map { imagesInfo -> MovieResultsInfo in
                        let moviesWithImagesInfo = paginatedMoviesResult.results.map { ($0, imagesInfo) }
                        let paginationInfo = paginatedMoviesResult.paginationInfo
                        let newPaginatedResult = PaginatedResult(results: moviesWithImagesInfo, paginationInfo: paginationInfo)
                        return (configuration, newPaginatedResult)
                    }
                }
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
        }.ensure {
            self.movieListListeners.forEach { $0.moviesServiceControllerDidFinishLoadingMovieList() }
        }.done { movieResultsInfo in
            self.movieListListeners.forEach { listener in
                listener.didFinishFetchingMovies(fromCategory: category, page: page, results: Result.Success(movieResultsInfo))
            }
        }.catch { error in
            self.movieListListeners.forEach { listener in
                listener.didFinishFetchingMovies(fromCategory: category, page: page, results: Result.Error(error))
            }
        }
    }
    
    func fetchMovieDetailForMovieId(_ movieId: Int, ignoringPersistance: Bool = false) {
        self.movieDetailListeners.forEach { $0.moviesServiceControllerDidStartLoadingMovieDetail() }
        configurationService.fetchConfiguration(ignoringPersistance: ignoringPersistance).then { configuration in
            return self.moviesService.fetchMovieDetailForMovieId(movieId, ignoringPersistance: ignoringPersistance).map { movieDetail in
                return (configuration, movieDetail)
            }
        }.ensure {
            self.movieDetailListeners.forEach { $0.moviesServiceControllerDidFinishLoadingMovieDetail() }
        }.done { (configuration, movieDetail) in
            self.movieDetailListeners.forEach { listener in
                listener.didFinishFetchingMovieDetail(with: Result.Success((configuration, movieDetail)))
            }
        }.catch { error in
            self.movieDetailListeners.forEach { listener in
                listener.didFinishFetchingMovieDetail(with: Result.Error(error))
            }
        }
    }
    
    func addMovieListListener(_ listener: MoviesServiceControllerMovieListListener) {
        if !movieListListeners.contains(where: { $0 === listener }) {
            movieListListeners.append(listener)
        }
    }
    
    func removeMovieListListener(_ listener: MoviesServiceControllerMovieListListener) {
        guard let index = movieListListeners.firstIndex(where: { $0 === listener }) else { return }
        movieListListeners.remove(at: index)
    }
    
    func addMovieDetailListener(_ listener: MoviesServiceControllerMovieDetailListener) {
        if !movieDetailListeners.contains(where: { $0 === listener }) {
            movieDetailListeners.append(listener)
        }
    }
    
    func removeMovieDetailListener(_ listener: MoviesServiceControllerMovieDetailListener) {
        guard let index = movieDetailListeners.firstIndex(where: { $0 === listener }) else { return }
        movieDetailListeners.remove(at: index)
    }
    
    init(configurationService: TMDBConfigurationService, moviesService: MoviesService, imagesInfoService: MovieImagesInfoService) {
        self.configurationService = configurationService
        self.moviesService = moviesService
        self.imagesInfoService = imagesInfoService
    }
}
