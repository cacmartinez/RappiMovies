import UIKit

enum ImageType {
    case poster
    case backdrop
}

struct ImageURLProvider {
    private let configuration: TMDBConfiguration
    
    func url(for imageType: ImageType, withWidth width: CGFloat, path: String) -> URL {
        let imageConfiguration = configuration.imageConfiguration
        let sizes: [String]
        switch imageType {
        case .backdrop:
            sizes = imageConfiguration.backdropSizes
        case .poster:
            sizes = imageConfiguration.posterSizes
        }
        let size = sizeForWidth(width: width, sizes: sizes)
        let urlString = "\(imageConfiguration.secureBaseURL)/\(size)/\(path)"
        return URL(string: urlString)!
    }
    
    /// Chooses the closest width that is bigger than the given width
    private func sizeForWidth(width: CGFloat, sizes: [String]) -> String {
        return sizes.first(where: { CGFloat(Int($0.dropFirst())!) > width }) ?? sizes.last!
    }
    
    init(configuration: TMDBConfiguration) {
        self.configuration = configuration
    }
}
