import Foundation
import PromiseKit

struct MovieImagesInfoService {
    let networkFetcher: MovieImagesInfoNetworkFetcher
    let persistanceFetcher: MovieImagesInfoPersistanceFetcher
    
    func fetchImagesInfoForMovieId(_ movieId: Int, ignoringPersistance: Bool = false) -> Promise<MediaImagesInfo> {
        let promise: Promise<MediaImagesInfo?>
        if ignoringPersistance {
            promise = Promise.value(nil)
        } else {
            promise = persistanceFetcher.fetchImagesInfoForMovieId(movieId)
        }
        
        return promise.then { imagesInfo -> Promise<MediaImagesInfo> in
            if let imagesInfo = imagesInfo {
                return Promise.value(imagesInfo)
            }
            return self.networkFetcher.fetchImagesInfoForMovieId(movieId).get { imagesInfo in
                self.persistanceFetcher.save(imagesInfo)
            }
        }
    }
    
    init(networkClient: NetworkClient, urlProvider: TMDBURLProviderProtocol, dateFormatter: DateFormatter) {
        networkFetcher = MovieImagesInfoNetworkFetcher(networkClient: networkClient, urlProvider: urlProvider)
        persistanceFetcher = MovieImagesInfoPersistanceFetcher(dateFormatter: dateFormatter)
    }
}
