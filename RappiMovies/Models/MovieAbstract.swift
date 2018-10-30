import Foundation

struct MovieAbstract {
    struct Vote {
        let count: Int
        let average: Double
        
        init(count: Int, average: Double) {
            self.count = count
            self.average = average
        }
    }
    
    struct ImagePaths {
        let poster: String?
        let backdrop: String?
        
        init(poster: String?, backdrop: String?) {
            self.poster = poster
            self.backdrop = backdrop
        }
    }
    
    let overview: String
    let releaseDate: Date
    let genreIds: [Int]
    let id: Int
    let originalTitle: String
    let originalLanguage: String
    let title: String
    let popularity: Double
    let hasVideo: Bool
    let vote: Vote
    let imagePaths: ImagePaths
    
    init(overview: String, releaseDate: Date, genreIds: [Int], id: Int, originalTitle: String, originalLanguage:String, title:String, popularity: Double, hasVideo: Bool, vote: Vote, imagePaths: ImagePaths) {
        self.overview = overview
        self.releaseDate = releaseDate
        self.genreIds = genreIds
        self.id = id
        self.originalTitle = originalTitle
        self.originalLanguage = originalLanguage
        self.title = title
        self.popularity = popularity
        self.hasVideo = hasVideo
        self.vote = vote
        self.imagePaths = imagePaths
    }
}

extension MovieAbstract: Decodable {
    enum CodingKeys: CodingKey {
        case posterPath
        case overview
        case releaseDate
        case genreIds
        case id
        case originalTitle
        case originalLanguage
        case title
        case backdropPath
        case popularity
        case voteCount
        case video
        case voteAverage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        let backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        let voteCount = try container.decode(Int.self, forKey: .voteCount)
        let voteAverage = try container.decode(Double.self, forKey: .voteAverage)
        
        overview = try container.decode(String.self, forKey: .overview)
        releaseDate = try container.decode(Date.self, forKey: .releaseDate)
        genreIds = try container.decode([Int].self, forKey: .genreIds)
        id = try container.decode(Int.self, forKey: .id)
        originalTitle = try container.decode(String.self, forKey: .originalTitle)
        originalLanguage = try container.decode(String.self, forKey: .originalLanguage)
        title = try container.decode(String.self, forKey: .title)
        popularity = try container.decode(Double.self, forKey: .popularity)
        hasVideo = try container.decode(Bool.self, forKey: .video)
        vote = Vote(count: voteCount, average: voteAverage)
        imagePaths = ImagePaths(poster: posterPath, backdrop: backdropPath)
    }
}
