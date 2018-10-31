import UIKit
import PromiseKit

protocol TMDBConfigurationServiceListener: AnyObject {
    func serviceDidFinishFetching(with result: Result<TMDBConfiguration>)
}

final class TMDBConfigurationService {
    private let networkFetcher: TMDBApiConfigurationFetcher
    private let persistanceFetcher: TMDBPersistanceConfigurationFetcher
    private var listeners: [TMDBConfigurationServiceListener] = []
    
    func fetchConfiguration(ignoringPersistance: Bool = false) -> Promise<TMDBConfiguration> {
        let promise: Promise<TMDBConfiguration?>
        if ignoringPersistance {
            promise = Promise.value(nil)
        } else {
            promise = persistanceFetcher.fetchConfiguration()
        }
        
        return promise.then { configuration -> Promise<TMDBConfiguration> in
            if let configuration = configuration {
                return Promise.value(configuration)
            } else {
                return self.networkFetcher.fetchConfiguration()
            }
        }
    }
    
    init(networkClient: NetworkClient, urlProvider: TMDBURLProviderProtocol, dateFormatter: DateFormatter) {
        networkFetcher = TMDBApiConfigurationFetcher(networkClient: networkClient, urlProvider: urlProvider)
        persistanceFetcher = TMDBPersistanceConfigurationFetcher(dateFormatter: dateFormatter)
    }
}
