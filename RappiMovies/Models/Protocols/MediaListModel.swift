import Foundation

protocol MediaListModel: ListModel {
    var id: Int { get }
    var title: String { get }
    var releaseDate: Date { get }
    var posterPath: String? { get }
    var backdropPath: String? { get }
}
