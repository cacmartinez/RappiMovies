import Foundation

protocol ListController {
    var viewModel: ListViewModel { get }
    var errorLoading: ((Error)->Void)? { get set }
    var listModelTapped: ((ListModel)->())? { get set }
    var newValuesAdded: ((_ values: [RowViewModel], _ addedValues: [RowViewModel])->Void)? { get set }
    
    func removeObservations()
    func start()
}

protocol PaginatedListController: ListController {
    var canLoadMore: Bool { get }
    func loadMore()
}
