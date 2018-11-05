import Foundation
import PromiseKit

struct MoviesNetworkFetcher: NetworkFetcher {
    private let networkClient: NetworkClient
    private let urlProvider: TMDBURLProviderProtocol
    
    func fetchMoviePage(_ page: Int, of category: MovieCategory) -> Promise<PaginatedResult<[MovieAbstract]>> {
        let url: URL
        switch category {
        case .Popular:
            url = urlProvider.url(for: .popularMovies(page: URLPage(integerLiteral: page)))
        case .TopRated:
            url = urlProvider.url(for: .topRatedMovies(page: URLPage(integerLiteral: page)))
        case .Upcoming:
            url = urlProvider.url(for: .upcomingMovies(page: URLPage(integerLiteral: page)))
        }
        return networkClient.get(url: url)
    }
    
    func fetchMovieDetailForMovieId(_ movieId: Int) -> Promise<MovieDetail> {
        let url = urlProvider.url(for: .movieDetail(movieId: movieId))
        return networkClient.get(url: url)
    }
    
    init(networkClient: NetworkClient, urlProvider: TMDBURLProviderProtocol) {
        self.networkClient = networkClient
        self.urlProvider = urlProvider
    }
}
