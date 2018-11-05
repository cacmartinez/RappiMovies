import Foundation
import PromiseKit

struct MovieImagesInfoPersistanceFetcher {
    let modelArchiver: ModelArchiver<MediaImagesInfo>
    
    func fetchImagesInfoForMovieId(_ movieId: Int) -> Promise<MediaImagesInfo?> {
        let fileName = String(describing: MediaImagesInfo.self) + "mv\(movieId)"
        return modelArchiver.retriveNonExpiredArchivedOfFileNamed(fileName)
    }
    
    func save(_ imagesInfo: MediaImagesInfo) {
        let fileName = String(describing: MediaImagesInfo.self) + "mv\(imagesInfo.id)"
        modelArchiver.save(imagesInfo, withFileName: fileName)
    }
    
    init(dateFormatter: DateFormatter) {
        modelArchiver = ModelArchiver(dateFormatter: dateFormatter, lifeSpan: 5)
    }
}
