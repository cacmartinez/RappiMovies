import Foundation

struct ConfigurationTestRequestHandler: URLRequestHandler {
    func handle(_ request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let data = """
            {
                "images": {
                    "secure_base_url": "https://image.tmdb.org/t/p/",
                    "backdrop_sizes": [
                        "w300",
                        "w780",
                        "w1280",
                        "original"
                    ],
                    "poster_sizes": [
                        "w92",
                        "w154",
                        "w185",
                        "w342",
                        "w500",
                        "w780",
                        "original"
                    ]
                }
            }
        """.data(using: .utf8)
        completionHandler(data, nil, nil)
    }
}
