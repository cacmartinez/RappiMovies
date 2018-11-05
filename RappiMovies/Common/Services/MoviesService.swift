import Foundation
import PromiseKit

struct MoviesService {
    private let networkFetcher: MoviesNetworkFetcher
    private let persistanceFetcher: MoviesPersistanceFetcherProtocol
    
    func fetchMoviePage(_ page: Int, of category: MovieCategory, ignoringPersistance: Bool = false) -> Promise<PaginatedResult<[MovieAbstract]>> {
        let promise: Promise<PaginatedResult<[MovieAbstract]>?>
        if ignoringPersistance {
            promise = Promise.value(nil)
        } else {
            promise = persistanceFetcher.fetchMoviePageResult(page, of: category)
        }
        
        return promise.then { paginatedMovieResult -> Promise<PaginatedResult<[MovieAbstract]>> in
            if let paginatedMovieResult = paginatedMovieResult, !paginatedMovieResult.results.isEmpty {
                return Promise.value(paginatedMovieResult)
            }
            return self.networkFetcher.fetchMoviePage(page, of: category).get { paginatedMovieResult in
                self.persistanceFetcher.add(paginatedMovieResult, to: category)
            }
        }
    }
    
    func fetchMovieDetailForMovieId(_ movieId: Int, ignoringPersistance: Bool) -> Promise<MovieDetail> {
        let promise: Promise<MovieDetail?>
        if ignoringPersistance {
            promise = Promise.value(nil)
        } else {
            promise = persistanceFetcher.fetchMovieDetailForMovieId(movieId)
        }
        
        return promise.then { movieDetail -> Promise<MovieDetail> in
            if let movieDetail = movieDetail {
                return Promise.value(movieDetail)
            }
            return self.networkFetcher.fetchMovieDetailForMovieId(movieId).get {
                movieDetail in
                self.persistanceFetcher.add(movieDetail)
            }
        }
    }
    
    init(networkClient: NetworkClient, urlProvider: TMDBURLProviderProtocol, fetcher: MoviesPersistanceFetcherProtocol) {
        networkFetcher = MoviesNetworkFetcher(networkClient: networkClient, urlProvider: urlProvider)
        self.persistanceFetcher = fetcher
    }
}
