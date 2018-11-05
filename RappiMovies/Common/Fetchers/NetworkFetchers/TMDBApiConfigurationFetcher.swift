import Foundation
import PromiseKit

struct TMDBApiConfigurationFetcher: NetworkFetcher {
    let networkClient: NetworkClient
    let urlProvider: TMDBURLProviderProtocol
    
    func fetchConfiguration() -> Promise<TMDBConfiguration> {
        let configurationURL = urlProvider.url(for: .configuration)
        return networkClient.get(url: configurationURL)
    }
    
    init(networkClient: NetworkClient, urlProvider: TMDBURLProviderProtocol) {
        self.networkClient = networkClient
        self.urlProvider = urlProvider
    }
}
