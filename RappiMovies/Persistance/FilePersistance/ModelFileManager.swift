import Foundation

struct ModelFileManager {
    private let modelsDirectory: URL
    
    /// Creates a file for the given data, or replaces the old one.
    func saveModelData(_ data: Data, fileName: String) {
        let filePath = "\(modelsDirectory.path)/\(fileName).txt"
        FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
    }
    
    func retriveModelDataForFileName(_ fileName: String) -> Data? {
        let fileURL = modelsDirectory.appendingPathComponent("/\(fileName).txt")
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        guard let data = try? Data(contentsOf: fileURL) else { fatalError("Error reading data from file") }
        return data
    }
    
    /// Deletes model data if it exists
    func deleteModelWithFileName(_ fileName: String) {
        let fileURL = modelsDirectory.appendingPathComponent("/\(fileName).txt")
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        guard (try? FileManager.default.removeItem(at: fileURL)) != nil else { fatalError("failed to remove file") }
    }
    
    init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectoryPath = paths[0]
        modelsDirectory = documentsDirectoryPath.appendingPathComponent("/models")
    }
}
