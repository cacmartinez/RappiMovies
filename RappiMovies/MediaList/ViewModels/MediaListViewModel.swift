import Foundation

class MediaListViewModel {
    let isLoading = Observable<Bool>(value: false)
    let rowViewModels = Observable<[MediaListRowViewModel]>(value: [])
    let rowViewModelsAdded = Observable<[MediaListRowViewModel]>(value: [])
    var canLoadMore = false
}
