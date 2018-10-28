import Foundation

struct TMDBPersistanceConfigurationFetcher {
    let modelArchiver: ModelArchiver<TMDBConfiguration>
    
    func fetchConfiguration() -> TMDBConfiguration? {
        return modelArchiver.retriveNonExpiredArchived()
    }
    
    func save(_ configuration: TMDBConfiguration) {
        modelArchiver.save(configuration)
    }
    
    init(dateFormatter: DateFormatter) {
        modelArchiver = ModelArchiver(dateFormatter: dateFormatter, lifeSpan: 5)
    }
}
