import Foundation
import PromiseKit

struct TMDBPersistanceConfigurationFetcher {
    let modelArchiver: ModelArchiver<TMDBConfiguration>
    
    func fetchConfiguration() -> Promise<TMDBConfiguration?> {
        return modelArchiver.retriveNonExpiredArchived()
    }
    
    func save(_ configuration: TMDBConfiguration) {
        modelArchiver.save(configuration)
    }
    
    init(dateFormatter: DateFormatter) {
        modelArchiver = ModelArchiver(dateFormatter: dateFormatter, lifeSpan: 5)
    }
}
