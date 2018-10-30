import Foundation

struct ArchivableModelWrapper<T: Codable>: Codable {
    let expirationDate: Date
    let model : T
}

extension ArchivableModelWrapper: Expirable {}
