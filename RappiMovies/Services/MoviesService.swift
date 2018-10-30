import Foundation
import CoreData

protocol MoviesServiceListener: AnyObject {
    func didFinishFetchingMovies(fromCategory category: MovieCategory, page:Int, results:Result<PaginatedResult<[MovieAbstract]>>)
}

final class MoviesService:Service {
    private let networkFetcher: MoviesNetworkFetcher
    private let persistanceFetcher: MoviesPersistanceFetcher
    private var listeners: [MoviesServiceListener] = []
    
    func fetchMoviePage(_ page: Int, of category: MovieCategory) {
        let paginatedMovieResult = persistanceFetcher.fetchMoviePageResult(page, of: category)
        if let paginatedMovieResult = paginatedMovieResult, !paginatedMovieResult.results.isEmpty {
            listeners.forEach { listener in
                listener.didFinishFetchingMovies(fromCategory: category, page: page, results: Result.Success(paginatedMovieResult))
            }
            return
        }
        
        networkFetcher.fetchMoviePage(page, of: category) { [weak self] result in
            guard let self = self else { return }
            if case .Success(let paginatedMovieResult) = result {
                self.persistanceFetcher.add(paginatedMovieResult, to: category)
            }
            self.listeners.forEach { listener in
                listener.didFinishFetchingMovies(fromCategory: category, page:page, results: result)
            }
        }
    }
    
    func addListener(listener: MoviesServiceListener) {
        if !listeners.contains(where: { $0 === listener }) {
            listeners.append(listener)
        }
    }
    
    func removeListener(listener: MoviesServiceListener) {
        guard let index = listeners.firstIndex(where: { $0 === listener }) else { return }
        listeners.remove(at: index)
    }
    
    init(networkClient: NetworkClient, urlProvider: TMDBURLProviderProtocol, fetcher: MoviesPersistanceFetcher) {
        networkFetcher = MoviesNetworkFetcher(networkClient: networkClient, urlProvider: urlProvider)
        self.persistanceFetcher = fetcher
    }
}
