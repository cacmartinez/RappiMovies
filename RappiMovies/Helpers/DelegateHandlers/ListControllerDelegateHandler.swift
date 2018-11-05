import UIKit

class ListControllerDelegateHandler: NSObject, UIScrollViewDelegate, UICollectionViewDelegate {
    let paginationHandler: (()->Void)?
    weak var listViewModel: ListViewModel?
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let paginationHandler = paginationHandler, isScrollViewAtBottom(scrollView) {
            paginationHandler()
        }
    }
    
    func isScrollViewAtBottom(_ scrollView: UIScrollView) -> Bool {
        return scrollView.contentSize.height - scrollView.contentOffset.y <= scrollView.bounds.height
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let listViewModel = listViewModel else { return }
        guard indexPath.row < listViewModel.rowViewModels.value.count else { return }
        let rowViewModel = listViewModel.rowViewModels.value[indexPath.row]
        if let tappableRowViewModel = rowViewModel as? ViewModelActionable {
            tappableRowViewModel.viewModelTapped?()
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    init(listViewModel: ListViewModel, paginationHandler: (()->Void)?) {
        self.paginationHandler = paginationHandler
        self.listViewModel = listViewModel
    }
}
