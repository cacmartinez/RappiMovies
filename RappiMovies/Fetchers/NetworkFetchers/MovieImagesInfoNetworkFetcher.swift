import Foundation
import PromiseKit

struct MovieImagesInfoNetworkFetcher: NetworkFetcher {
    let networkClient: NetworkClient
    let urlProvider: TMDBURLProviderProtocol
    
    func fetchImagesInfoForMovieId(_ movieId: Int) -> Promise<MediaImagesInfo> {
        let url = urlProvider.url(for: .movieImagesInfo(movieId: movieId))
        return networkClient.get(url: url)
    }
    
    init(networkClient: NetworkClient, urlProvider: TMDBURLProviderProtocol) {
        self.networkClient = networkClient
        self.urlProvider = urlProvider
    }
}
