import Foundation

protocol MediaListController {
    var viewModel: ListViewModel { get }
    var errorLoading: ((Error)->Void)? { get set }
    var mediaTapped: ((ListModel)->())? { get set }
    var newValuesAdded: ((_ values: [RowViewModel], _ addedValues: [RowViewModel])->Void)? { get set }
    
    func removeObservations()
    func start()
}

protocol PaginatedMediaListController: MediaListController {
    var canLoadMore: Bool { get }
    func loadMore()
}
