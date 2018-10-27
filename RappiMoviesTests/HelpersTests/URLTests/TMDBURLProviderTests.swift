import XCTest
@testable import RappiMovies

class TMDBURLProviderTests: XCTestCase {
    let urlProvider = TMDBURLProvider(baseURL: "https://api.themoviedb.org", version: 3, apiKey: "123")
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func testURLProviderConfigurationEndpoint() {
        XCTAssertEqual(urlProvider.url(for: .configuration).absoluteString, "https://api.themoviedb.org/3/configuration?api_key=123")
    }
    
    func testURLProviderPopularMoviesEndpoint() {
        let providerURL = urlProvider.url(for: .popularMovies(page: 7))
        let providerURLString = providerURL.absoluteString
        
        XCTAssertEqual(providerURL.path, "/3/movie/popular")
        XCTAssertEqual(getQueryStringParameter(url: providerURLString, param: "api_key"), "123")
        XCTAssertEqual(getQueryStringParameter(url: providerURLString, param: "page"), "7")
    }
    
    func testURLProviderTopRatedMoviesEndpoint() {
        let providerURL = urlProvider.url(for: .topRatedMovies(page: 9))
        let providerURLString = providerURL.absoluteString
        
        XCTAssertEqual(providerURL.path, "/3/movie/top_rated")
        XCTAssertEqual(getQueryStringParameter(url: providerURLString, param: "api_key"), "123")
        XCTAssertEqual(getQueryStringParameter(url: providerURLString, param: "page"), "9")
    }
    
    func testURLProviderUpcomingMoviesEndpoint() {
        let providerURL = urlProvider.url(for: .upcomingMovies(page: 10))
        let providerURLString = providerURL.absoluteString
        
        XCTAssertEqual(providerURL.path, "/3/movie/upcoming")
        XCTAssertEqual(getQueryStringParameter(url: providerURLString, param: "api_key"), "123")
        XCTAssertEqual(getQueryStringParameter(url: providerURLString, param: "page"), "10")
    }
}
