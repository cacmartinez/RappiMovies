import Foundation

protocol MediaListController {
    var viewModel: MediaListViewModel { get }
    var errorLoading: ((Error)->Void)? { get }
    var mediaTapped: ((MediaListModel)->())? { get }
    
    func removeObservations()
    func start()
    func loadMore()
}
