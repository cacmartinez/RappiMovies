import UIKit

protocol MediaListModel {
    var title: String { get }
    var releaseDate: Date { get }
    var posterPath: String? { get }
    var backdropPath: String? { get }
}

class MediaListRowViewModel: ViewModelActionable, RowViewModel {
    let title: String
    let releaseDate: String
    let posterPath: String?
    let backdropPath: String?
    let imageURLProvider: ImageURLProvider
    let posterAspectRatio: Double?
    let backdropAspectRatio: Double?
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
        backdropAspectRatio = imagesInfo.backdrops.first(where: { $0.filePath == mediaListModel.backdropPath })?.aspectRatio
        posterAspectRatio = imagesInfo.posters.first(where: { $0.filePath == mediaListModel.posterPath })?.aspectRatio
    }
}
