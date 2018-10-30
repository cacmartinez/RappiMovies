import Foundation

protocol MediaListController {
    var viewModel: MediaListViewModel { get }
    var errorLoading: ((Error)->Void)? { get set }
    var mediaTapped: ((MediaListModel)->())? { get set }
    var newValuesAdded: ((_ values: [MediaListRowViewModel], _ addedValues: [MediaListRowViewModel])->Void)? { get set }
    
    func removeObservations()
    func start()
    func loadMore()
}
