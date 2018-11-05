import Foundation

struct MovieDetail {
    struct ImagePaths {
        let poster: String?
        let backdrop: String?
        
        init(poster: String?, backdrop: String?) {
            self.poster = poster
            self.backdrop = backdrop
        }
    }
    
    struct Genre {
        let id: Int
        let name: String
    }
    
    struct ProductionCompany {
        let id: Int
        let name: String
    }
    
    struct ProductionCountry {
        let name: String
    }
    
    struct Video {
        let id: String
        let key: String
        let name: String
        let site: String
        let size: Int
        let type: String
    }
    
    let id: Int
    let title: String
    let overview: String?
    let releaseDate: Date
    let imagePaths: ImagePaths
    let budget: Int
    let homepage: URL?
    let originalLanguage: String
    let originalTitle: String
    let productionCompanies: [ProductionCompany]
    let productionCountries: [ProductionCountry]
    let revenue: Int
    let imagesInfo: MediaImagesInfo?
    let videos: [Video]?
}

extension MovieDetail.Genre: Decodable {}
extension MovieDetail.ProductionCountry: Decodable {}
extension MovieDetail.ProductionCompany: Decodable {}
extension MovieDetail.Video: Decodable {}

extension MovieDetail: Decodable {
    enum CodingKeys: CodingKey {
        case id
        case title
        case overview
        case releaseDate
        case posterPath
        case backdropPath
        case budget
        case homepage
        case originalLanguage
        case originalTitle
        case productionCompanies
        case productionCountries
        case revenue
        case images
        case videos
    }
    
    enum VideosCodingKeys: CodingKey {
        case results
    }
    
    enum ImagesInfoContainer: CodingKey {
        case posters
        case backdrops
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let videoContainer = try container.nestedContainer(keyedBy: VideosCodingKeys.self, forKey: .videos)
        let mediaImagesInfoContainer = try container.nestedContainer(keyedBy: ImagesInfoContainer.self, forKey: .images)
        
        let posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        let backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        let postersInfo = try mediaImagesInfoContainer.decodeIfPresent([MediaImagesInfo.ImageInfo].self, forKey: .posters)
        let backdropsInfo = try mediaImagesInfoContainer.decodeIfPresent([MediaImagesInfo.ImageInfo].self, forKey: .backdrops)
        
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        releaseDate = try container.decode(Date.self, forKey: .releaseDate)
        imagePaths = ImagePaths(poster: posterPath, backdrop: backdropPath)
        budget = try container.decode(Int.self, forKey: .budget)
        homepage = try container.decodeIfPresent(URL.self, forKey: .homepage)
        originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
        originalTitle = try container.decode(String.self, forKey: .originalTitle)
        productionCompanies = try container.decode([ProductionCompany].self, forKey: .productionCompanies)
        productionCountries = try container.decode([ProductionCountry].self, forKey: .productionCountries)
        revenue = try container.decode(Int.self, forKey: .revenue)
        if let postersInfo = postersInfo,
            let backdropsInfo = backdropsInfo {
            imagesInfo = MediaImagesInfo(id: id, posters: postersInfo, backdrops: backdropsInfo)
        } else {
            imagesInfo = nil
        }
        videos = try videoContainer.decodeIfPresent([Video].self, forKey: .results)
    }
}
