import UIKit

protocol TMDBConfigurationServiceListener: AnyObject {
    func serviceDidFinishFetching(with result: Result<TMDBConfiguration>)
}

final class TMDBConfigurationService: Service {
    private let networkFetcher: TMDBApiConfigurationFetcher
    private let persistanceFetcher: TMDBPersistanceConfigurationFetcher
    private var listeners: [TMDBConfigurationServiceListener] = []
    
    func fetchConfiguration(ignoringPersistance: Bool = false) {
        if !ignoringPersistance,
            let configuration = persistanceFetcher.fetchConfiguration() {
            self.listeners.forEach({ listener in
                listener.serviceDidFinishFetching(with: Result.Success(configuration))
            })
            return
        }
        
        networkFetcher.fetchConfiguration { [weak self] response in
            guard let self = self else { return }
            if case .Success(let configuration) = response {
                self.persistanceFetcher.save(configuration)
            }
            self.listeners.forEach({ listener in
                listener.serviceDidFinishFetching(with: response)
            })
        }
    }
    
    func addListener(listener: TMDBConfigurationServiceListener) {
        if !listeners.contains(where: { $0 === listener }) {
            listeners.append(listener)
        }
    }

    func removeListener(listener: TMDBConfigurationServiceListener) {
        guard let index = listeners.firstIndex(where: { $0 === listener }) else { return }
        listeners.remove(at: index)
    }
    
    init(networkClient: NetworkClient, urlProvider: TMDBURLProviderProtocol, dateFormatter: DateFormatter) {
        networkFetcher = TMDBApiConfigurationFetcher(networkClient: networkClient, urlProvider: urlProvider)
        persistanceFetcher = TMDBPersistanceConfigurationFetcher(dateFormatter: dateFormatter)
    }
}
