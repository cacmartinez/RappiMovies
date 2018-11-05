import Foundation

class MediaDetailViewModel: ListViewModel {
    var isLoading = Observable<Bool>(value: false)
    var rowViewModels = Observable<[RowViewModel]>(value: [])
    let supportsLoadingIndicatorCell: Bool = false
}
