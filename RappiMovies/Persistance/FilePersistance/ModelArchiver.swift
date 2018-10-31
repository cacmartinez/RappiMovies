import Foundation
import PromiseKit

typealias Days = Int

struct ModelArchiver<Model: Codable> {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    let lifeSpan: Days
    let modelFileManager = ModelFileManager()
    let fileName = String(describing: Model.self)
    
    func save(_ model: Model) {
        guard let expirationDate = Calendar.current.date(byAdding: .day, value: lifeSpan, to: Date()) else { fatalError("Was not able to generate expiration date from life span") }
        let archiveWrapper = ArchivableModelWrapper(expirationDate: expirationDate, model: model)
        guard let jsonData = try? encoder.encode(archiveWrapper) else { fatalError("Was not able to encode model when saving") }
        modelFileManager.saveModelData(jsonData, fileName: fileName)
    }
    
    /// Returns archived object if it hasn't expired.
    func retriveNonExpiredArchived() -> Promise<Model?> {
        return Promise { seal in
            guard let jsonData = modelFileManager.retriveModelDataForFileName(fileName) else {
                return seal.fulfill(nil)
            }
            guard let wrappedModel = try? decoder.decode(ArchivableModelWrapper<Model>.self, from: jsonData) else { fatalError("Error decoding from json") }
            if wrappedModel.isExpired() { return seal.fulfill(nil) }
            return seal.fulfill(wrappedModel.model)
        }
        
    }
    
    func deleteArchived() {
        modelFileManager.deleteModelWithFileName(fileName)
    }
    
    init(dateFormatter: DateFormatter, lifeSpan: Days) {
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        self.lifeSpan = lifeSpan
    }
}
