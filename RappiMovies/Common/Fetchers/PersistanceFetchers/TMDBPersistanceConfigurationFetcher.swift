import Foundation
import PromiseKit

struct TMDBPersistanceConfigurationFetcher {
    let modelArchiver: ModelArchiver<TMDBConfiguration>
    let fileName = String(describing: TMDBConfiguration.self)
    
    func fetchConfiguration() -> Promise<TMDBConfiguration?> {
        return modelArchiver.retriveNonExpiredArchivedOfFileNamed(fileName)
    }
    
    func save(_ configuration: TMDBConfiguration) {
        modelArchiver.save(configuration, withFileName:fileName)
    }
    
    init(dateFormatter: DateFormatter) {
        modelArchiver = ModelArchiver(dateFormatter: dateFormatter, lifeSpan: 5)
    }
}
