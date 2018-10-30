import Foundation

struct MoviesNetworkFetcher: NetworkFetcher {
    private let networkClient: NetworkClient
    private let urlProvider: TMDBURLProviderProtocol
    
    func fetchMoviePage(_ page: Int, of category: MovieCategory, result: @escaping ResultBlock<PaginatedResult<[MovieAbstract]>>) {
        let url: URL
        switch category {
        case .Popular:
            url = urlProvider.url(for: .popularMovies(page: URLPage(integerLiteral: page)))
        case .TopRated:
            url = urlProvider.url(for: .topRatedMovies(page: URLPage(integerLiteral: page)))
        case .Upcoming:
            url = urlProvider.url(for: .upcomingMovies(page: URLPage(integerLiteral: page)))
        }
        networkClient.get(url: url, callback: result)
    }
    
    init(networkClient: NetworkClient, urlProvider: TMDBURLProviderProtocol) {
        self.networkClient = networkClient
        self.urlProvider = urlProvider
    }
}
