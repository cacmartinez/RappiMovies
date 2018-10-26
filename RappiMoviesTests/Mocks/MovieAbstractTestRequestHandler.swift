import Foundation

struct MovieAbstractTestRequestHandler: URLRequestHandler {
    func handle(_ request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let data = """
            {
                "vote_count": 1583,
                "id": 335983,
                "video": false,
                "vote_average": 6.6,
                "title": "Venom",
                "popularity": 371.566,
                "poster_path": "/2uNW4WbgBXL25BAbXGLnLqX71Sw.jpg",
                "original_language": "en",
                "original_title": "VenomOriginal",
                "genre_ids": [
                    878,
                    28,
                    80,
                    28,
                    27
                ],
                "backdrop_path": "/VuukZLgaCrho2Ar8Scl9HtV3yD.jpg",
                "adult": false,
                "overview": "When Eddie Brock acquires the powers of a symbiote, he will have to release his alter-ego \\"Venom\\" to save his life.",
                "release_date": "2018-10-03"
            }
        """.data(using: .utf8)
        completionHandler(data, nil, nil)
    }
}
