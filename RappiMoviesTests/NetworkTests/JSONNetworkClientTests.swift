import XCTest
import PromiseKit
@testable import RappiMovies

class JSONNetworkClientTests: XCTestCase {
    var dateFormatter = DateFormatter()
    
    override func setUp() {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en-US")
    }
    
    func testConfigurationDecoding() {
        let requestHandler = ConfigurationTestRequestHandler()
        let networkClient = JSONNetworkClient(dateFormatter: dateFormatter, requestHandler: requestHandler)
        
        let expectation = XCTestExpectation(description: "Wait for network client")
        
        let promise: Promise<TMDBConfiguration> = networkClient.get(url: URL(string: "test.com")!)
        promise.done { configuration in
            XCTAssertEqual(configuration.imageConfiguration.secureBaseURL, "https://image.tmdb.org/t/p/")
            XCTAssertEqual(configuration.imageConfiguration.posterSizes, ["w92", "w154", "w185", "w342", "w500", "w780", "original"])
            XCTAssertEqual(configuration.imageConfiguration.backdropSizes, ["w300", "w780", "w1280", "original"])
        }.catch { error in
            XCTAssert(false)
        }.finally {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testMovieAbstractDecoding() {
        let requestHandler = MovieAbstractTestRequestHandler()
        let networkClient = JSONNetworkClient(dateFormatter: dateFormatter, requestHandler: requestHandler)
        
        let expectation = XCTestExpectation(description: "Wait for network client")
        
        let promise: Promise<MovieAbstract> = networkClient.get(url: URL(string: "test.com")!)
        promise.done { movie in
            XCTAssertEqual(movie.vote.count, 1583)
            XCTAssertEqual(movie.id, 335983)
            XCTAssertEqual(movie.hasVideo, false)
            XCTAssertEqual(movie.vote.average, 6.6)
            XCTAssertEqual(movie.title, "Venom")
            XCTAssertEqual(movie.popularity, 371.566)
            XCTAssertEqual(movie.imagePaths.poster, "/2uNW4WbgBXL25BAbXGLnLqX71Sw.jpg")
            XCTAssertEqual(movie.originalLanguage, "en")
            XCTAssertEqual(movie.originalTitle, "VenomOriginal")
            XCTAssertEqual(movie.genreIds, [878, 28, 80, 28, 27])
            XCTAssertEqual(movie.imagePaths.backdrop, "/VuukZLgaCrho2Ar8Scl9HtV3yD.jpg")
            XCTAssertEqual(movie.overview, "When Eddie Brock acquires the powers of a symbiote, he will have to release his alter-ego \"Venom\" to save his life.")
        }.catch{ error in
            XCTAssert(false)
        }.finally {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1)
    }
}
