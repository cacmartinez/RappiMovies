import UIKit
import SDWebImage

class ImageCell: UICollectionViewCell, ConfigurableCell {
    let imageView = UIImageView()
    var imageViewModel: ImageViewModel?
    var heightConstraint: NSLayoutConstraint? = nil
    var aspectRatioConstraint: NSLayoutConstraint? = nil
    var maximumHeigthConstraint: NSLayoutConstraint? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
        setupConstraints()
    }
    
    private func initialSetup() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        imageView.addGestureRecognizer(tapGesture)
        
        contentView.addSubview(imageView)
    }
    
    private func setupConstraints() {
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        let leftConstraint = imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor)
//        leftConstraint.priority = .defaultLow
        leftConstraint.isActive = true
        let rightConstraint = imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
//        rightConstraint.priority = .defaultLow
        rightConstraint.isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
    }
    
    func setup(with rowViewModel: RowViewModel) {
        guard let imageViewModel = rowViewModel as? ImageViewModel else {
            fatalError("unexpected view model sent to view")
        }
        
        self.imageViewModel = imageViewModel
        
        imageViewModel.imageBackgroundColor.addObserver { [weak self] backgroundColor in
            self?.imageView.backgroundColor = backgroundColor
        }
        
        imageViewModel.dimensionsData.addObserver { [weak self] dimensionsData in
            guard let dimensionsData = imageViewModel.dimensionsData.value,
                let self = self else {
                return
            }
            
            self.aspectRatioConstraint = self.imageView.widthAnchor.constraint(equalTo: self.imageView.heightAnchor, multiplier: dimensionsData.aspectRatio)
            self.aspectRatioConstraint?.priority = .required
            self.aspectRatioConstraint?.isActive = true
            
            if let constraintPreference = imageViewModel.constraintPreference {
                switch constraintPreference {
                case .constantHeight:
                    if let heightConstraint = self.heightConstraint {
                        heightConstraint.constant = dimensionsData.height
                    } else {
                        self.heightConstraint = self.imageView.heightAnchor.constraint(equalToConstant: dimensionsData.height)
                    }
                    self.heightConstraint?.priority = .required
                    self.heightConstraint?.isActive = true
                case .aspectRatioWithMaximumHeight(maximumHeight: let maxHeight):
                    if let maximumHeightConstraint = self.maximumHeigthConstraint {
                        maximumHeightConstraint.constant = maxHeight
                    } else {
                        self.maximumHeigthConstraint = self.imageView.heightAnchor.constraint(lessThanOrEqualToConstant: maxHeight)
                    }
                    self.maximumHeigthConstraint?.isActive = true
                }
            }
        }
        
        imageViewModel.urlData.addObserver { [weak self] urlData in
            guard let urlData = urlData,
            let dimensionsData = imageViewModel.dimensionsData.value,
            let self = self else {
                return
            }
            let url = urlData.urlProvider.url(for: .poster, withWidth: dimensionsData.width, path: urlData.imagePath)
            self.imageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    @objc func didTapImage() {
        imageViewModel?.viewModelTapped?()
    }
    
    override func prepareForReuse() {
        maximumHeigthConstraint?.isActive = false
        aspectRatioConstraint?.isActive = false
        aspectRatioConstraint = nil
        heightConstraint?.isActive = false
        imageViewModel?.imageBackgroundColor.removeObserver()
        imageViewModel?.urlData.removeObserver()
        imageViewModel = nil
        imageView.image = nil
    }
}
