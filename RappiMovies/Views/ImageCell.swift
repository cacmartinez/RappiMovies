import UIKit
import SDWebImage

class ImageCell: UICollectionViewCell, ConfigurableCell {
    let imageView = UIImageView()
    var imageViewModel: ImageViewModel?
    
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
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    func setup(with rowViewModel: RowViewModel) {
        guard let imageViewModel = rowViewModel as? ImageViewModel else {
            fatalError("unexpected view model sent to view")
        }
        
        self.imageViewModel = imageViewModel
        
        imageViewModel.imageBackgroundColor.addObserver { [weak self] backgroundColor in
            self?.imageView.backgroundColor = backgroundColor
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
        imageViewModel?.imageBackgroundColor.removeObserver()
        imageViewModel?.urlData.removeObserver()
        imageViewModel = nil
        imageView.image = nil
    }
}
