import Foundation

struct TMDBApiConfigurationFetcher: NetworkFetcher {
    let networkClient: NetworkClient
    let urlProvider: TMDBURLProviderProtocol
    
    func fetchConfiguration(onCompletion: @escaping ResultBlock<TMDBConfiguration>) {
        let configurationURL = urlProvider.url(for: .configuration)
        networkClient.get(url: configurationURL, callback: onCompletion)
    }
    
    init(networkClient: NetworkClient, urlProvider: TMDBURLProviderProtocol) {
        self.networkClient = networkClient
        self.urlProvider = urlProvider
    }
}
