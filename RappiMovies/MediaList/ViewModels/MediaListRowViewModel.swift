import UIKit

class MediaListRowViewModel: ViewModelActionable, RowViewModel {
    let title: String
    let releaseDate: String
    let posterPath: String?
    let backdropPath: String?
    let imageURLProvider: ImageURLProvider
    let posterAspectRatio: CGFloat?
    let backdropAspectRatio: CGFloat?
    var viewModelTapped: (() -> Void)?
    
    var cellType: ConfigurableCollectionViewCell.Type {
        return MediaListCell.self
    }
    
    init(mediaListModel: MediaListModel, imagesInfo: MediaImagesInfo, imageURLProvider: ImageURLProvider, dateFormatter: DateFormatter) {
        title = mediaListModel.title
        releaseDate = dateFormatter.string(from: mediaListModel.releaseDate)
        posterPath = mediaListModel.posterPath
        backdropPath = mediaListModel.backdropPath
        self.imageURLProvider = imageURLProvider
        backdropAspectRatio = (imagesInfo.backdrops.first(where: { $0.filePath == mediaListModel.backdropPath })?.aspectRatio).map { CGFloat($0) }
        posterAspectRatio = (imagesInfo.posters.first(where: { $0.filePath == mediaListModel.posterPath })?.aspectRatio).map { CGFloat($0) }
    }
}
