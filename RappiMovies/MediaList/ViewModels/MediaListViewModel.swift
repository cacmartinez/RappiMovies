import Foundation

protocol ListViewModel {
    var isLoading: Observable<Bool> { get }
    var rowViewModels: Observable<[RowViewModel]> { get }
}

class MediaListViewModel: ListViewModel {
    let isLoading = Observable<Bool>(value: false)
    let rowViewModels = Observable<[RowViewModel]>(value: [])
}
