import Foundation

struct MediaImagesInfo {
    struct ImageInfo {
        let filePath: String
        let aspectRatio: Double
        let width: Int
        let height: Int
    }
    
    let id: Int
    let posters: [ImageInfo]
    let backdrops: [ImageInfo]
}

extension MediaImagesInfo.ImageInfo: Codable {}
extension MediaImagesInfo: Codable {}
