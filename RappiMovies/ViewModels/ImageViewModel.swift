import UIKit

class ImageViewModel: RowViewModel, ViewModelActionable {
    enum ConstraintPreference {
        case constantHeight
        case aspectRatioWithMaximumHeight(maximumHeight: CGFloat)
    }
    
    var viewModelTapped: (() -> Void)?
    
    struct URLData {
        let imagePath: String
        let urlProvider: ImageURLProvider
    }
    
    struct DimensionsData {
        let height: CGFloat
        let width: CGFloat
        let aspectRatio: CGFloat
        
        init(height: Int, width: Int, aspectRatio: Double) {
            self.height = CGFloat(height)
            self.width = CGFloat(width)
            self.aspectRatio = CGFloat(aspectRatio)
        }
    }
    
    var constraintPreference: ConstraintPreference? = nil
    let urlData: Observable<URLData?>
    let dimensionsData: Observable<DimensionsData?>
    var imageBackgroundColor = Observable<UIColor>(value: AppColors.imageDefaultBackgroundColor)
    
    var cellType: ConfigurableCollectionViewCell.Type {
        return ImageCell.self
    }
    
    init(dimensionsData: DimensionsData?, urlData: URLData? = nil) {
        self.dimensionsData = Observable(value: dimensionsData)
        self.urlData = Observable(value: urlData)
    }
}
