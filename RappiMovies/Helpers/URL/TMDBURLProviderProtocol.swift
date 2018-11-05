import Foundation

enum TMDBEndpoint {
    case configuration
    case popularMovies(page: URLPage)
    case topRatedMovies(page: URLPage)
    case upcomingMovies(page: URLPage)
    case movieImagesInfo(movieId: Int)
    case movieDetail(movieId: Int)
    
    var path: String {
        switch self {
        case .configuration:
            return "/configuration"
        case .popularMovies:
            return "/movie/popular"
        case .topRatedMovies:
            return "/movie/top_rated"
        case .upcomingMovies:
            return "/movie/upcoming"
        case .movieImagesInfo(movieId: let movieId):
            return "/movie/\(movieId)/images"
        case .movieDetail(movieId: let movieId):
            return "/movie/\(movieId)"
        }
    }
    
    var queryParameters: [String: String] {
        switch self {
        case .configuration:
            return [:]
        case .popularMovies(page: let page):
            return page.queryParameters
        case .topRatedMovies(page: let page):
            return page.queryParameters
        case .upcomingMovies(page: let page):
            return page.queryParameters
        case .movieImagesInfo:
            return [:]
        case .movieDetail:
            return ["append_to_response":"images,videos"]
        }
    }
}

struct URLPage: ExpressibleByIntegerLiteral {
    private let page: Int
    
    init(integerLiteral value: IntegerLiteralType) {
        page = value
    }
    
    fileprivate var queryParameters: [String: String] {
        return ["page": String(page)]
    }
}

protocol TMDBURLProviderProtocol {
    init(baseURL: String, version: Int, apiKey: String)
    
    func url(for endpoint: TMDBEndpoint) -> URL
}
