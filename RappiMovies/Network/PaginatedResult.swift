import Foundation

struct PaginationInfo {
    let totalPages: Int
}

struct PaginatedResult<T> {
    let results: T
    let paginationInfo: PaginationInfo
    
    init(results: T, paginationInfo: PaginationInfo) {
        self.results = results
        self.paginationInfo = paginationInfo
    }
}

extension PaginatedResult: Decodable where T:Decodable {
    enum CodingKeys: CodingKey {
        case results
        case totalPages
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let totalPages = try container.decode(Int.self, forKey: .totalPages)
        
        results = try container.decode(T.self, forKey: .results)
        paginationInfo = PaginationInfo(totalPages: totalPages)
    }
}
