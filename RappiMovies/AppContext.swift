import Foundation

struct AppContext {
    let dateFormatter: DateFormatter
    let networkClient: NetworkClient
    
    let moviesService: MoviesService
    let configurationController: TMDBConfigurationServiceController
}
