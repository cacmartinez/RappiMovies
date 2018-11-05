import Foundation

protocol NetworkFetcher {
    init(networkClient:NetworkClient, urlProvider:TMDBURLProviderProtocol)
}
