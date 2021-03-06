import Foundation

struct TMDBConfiguration {
    struct ImageConfiguration {
        let secureBaseURL: String
        let backdropSizes: [String]
        let posterSizes: [String]
    }
    
    let imageConfiguration: ImageConfiguration
}

extension TMDBConfiguration.ImageConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case secureBaseURL = "secureBaseUrl"
        case backdropSizes
        case posterSizes
    }
}

extension TMDBConfiguration: Codable {
    enum CodingKeys: String, CodingKey {
        case imageConfiguration = "images"
    }
}
