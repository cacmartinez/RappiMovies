import Foundation

class MediaListViewModel {
    let isLoading = Observable<Bool>(value: false)
    let rowViewModels = Observable<[MediaListRowViewModel]>(value: [])
    var canLoadMore = false
}
