import UIKit
import CoreData

protocol EnvironmentConfiguration {
    var baseURL: String { get }
    var version: Int { get }
    var apiKey: String { get }
}

struct DevelopmentConfiguration: EnvironmentConfiguration {
    let baseURL = "https://api.themoviedb.org"
    let version = 3
    let apiKey = "0230007a25eae22964af97e9f7fa1524"
}

class AppCoordinator: Coordinator {
    private let rootViewController: UINavigationController
    private let window: UIWindow
    
    private lazy var mediaListCoordinator: MediaListCoordinator = {
        return MediaListCoordinator(presenter: rootViewController, context: appContext)
    }()
    
    private lazy var appContext: AppContext = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en-US")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let networkClient = JSONNetworkClient(dateFormatter: dateFormatter)
        
        let configuration: EnvironmentConfiguration = DevelopmentConfiguration()
        
        let urlProvider = TMDBURLProvider(baseURL: configuration.baseURL, version: configuration.version, apiKey: configuration.apiKey)
        
        let moviePersistanceFetcher = MoviesPersistanceFetcher(context: persistentContainer.viewContext)
        
        let moviesService = MoviesService(networkClient: networkClient, urlProvider: urlProvider, fetcher:moviePersistanceFetcher)
        
        let configurationService = TMDBConfigurationService(networkClient: networkClient, urlProvider: urlProvider, dateFormatter: dateFormatter)
        
        let configurationController = TMDBConfigurationServiceController(service: configurationService)
        
        return AppContext(dateFormatter: dateFormatter, networkClient: networkClient, moviesService: moviesService, configurationController: configurationController)
    }()
    
    init(window: UIWindow) {
        rootViewController = UINavigationController()
        self.window = window
    }
    
    func start() {
        window.rootViewController = rootViewController
        mediaListCoordinator.start()
        window.makeKeyAndVisible()
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "RappiMovies")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
