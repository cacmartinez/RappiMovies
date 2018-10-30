import Foundation

final class TMDBConfigurationServiceController {
    private let service: TMDBConfigurationService
    var callBlock: ResultBlock<TMDBConfiguration>? = nil
    
    func configuration(_ predicate: @escaping ResultBlock<TMDBConfiguration> ) {
        callBlock = predicate
        service.fetchConfiguration()
    }
    
    init(service: TMDBConfigurationService) {
        self.service = service
        service.addListener(listener: self)
    }
}

extension TMDBConfigurationServiceController: TMDBConfigurationServiceListener {
    func serviceDidFinishFetching(with result: Result<TMDBConfiguration>) {
        callBlock?(result)
        callBlock = nil
    }
}
