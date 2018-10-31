import Foundation
import PromiseKit

final class MoviesService {
    private let networkFetcher: MoviesNetworkFetcher
    private let persistanceFetcher: MoviesPersistanceFetcher
    
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
            return self.networkFetcher.fetchMoviePage(page, of: category)
        }
    }
    
    init(networkClient: NetworkClient, urlProvider: TMDBURLProviderProtocol, fetcher: MoviesPersistanceFetcher) {
        networkFetcher = MoviesNetworkFetcher(networkClient: networkClient, urlProvider: urlProvider)
        self.persistanceFetcher = fetcher
    }
}
