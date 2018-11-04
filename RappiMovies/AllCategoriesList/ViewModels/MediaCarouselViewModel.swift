import UIKit

class MediaCarouselViewModel: RowViewModel, ListViewModel, ViewModelActionable {
    let isLoading = Observable<Bool>(value: false)
    let rowViewModels: Observable<[RowViewModel]>
    let supportsLoadingIndicatorCell: Bool = false
    
    let title: String
    var titleColor = AppColors.listCellColor
    var carouselDataSource: UICollectionViewDataSource?
    
    var cellType: ConfigurableCollectionViewCell.Type {
        return MediaCarouselCell.self
    }
    
    var viewModelTapped: (() -> Void)?
    
    init(title: String, numberOfElements: Int, dimensionData: ImageViewModel.DimensionsData) {
        self.title = title
        
        let imageViewModels = (1...numberOfElements).map { _ in
            return ImageViewModel(dimensionsData: dimensionData)
        }
        
        self.rowViewModels = Observable.init(value: imageViewModels)
    }
}
