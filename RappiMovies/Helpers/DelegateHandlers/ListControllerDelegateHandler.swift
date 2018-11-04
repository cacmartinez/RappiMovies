import UIKit

class ListControllerDelegateHandler: NSObject, UIScrollViewDelegate, UICollectionViewDelegate {
    let paginationHandler: (()->Void)?
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let paginationHandler = paginationHandler, isScrollViewAtBottom(scrollView) {
            paginationHandler()
        }
    }
    
    func isScrollViewAtBottom(_ scrollView: UIScrollView) -> Bool {
        return scrollView.contentSize.height - scrollView.contentOffset.y <= scrollView.bounds.height
    }
    
    init(paginationHandler: (()->Void)?) {
        self.paginationHandler = paginationHandler
    }
}
