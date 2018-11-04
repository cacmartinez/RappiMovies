import UIKit

class MediaCarouselCell: UICollectionViewCell, ConfigurableCell {
    private let collectionView: UICollectionView
    private let flowLayout = UICollectionViewFlowLayout()
    private let titleLabel = UILabel()
    private let showAllButton = UIButton()
    private let objectSpace: CGFloat = 8
    private var carouselViewModel: MediaCarouselViewModel?
    private var heigthConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        collectionView = UICollectionView(frame: frame, collectionViewLayout: flowLayout)
        super.init(frame: frame)
        initialSetup()
        initialConstraints()
        let horizontalMargins = layoutMargins.left + layoutMargins.right
        collectionView.widthAnchor.constraint(equalToConstant: frame.width - horizontalMargins).isActive = true
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        super.init(coder: aDecoder)
        initialSetup()
        initialConstraints()
    }
    
    var titleLabelConstraints: [NSLayoutConstraint] {
        return [
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: layoutMargins.left),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: layoutMargins.top),
            titleLabel.rightAnchor.constraint(equalTo: showAllButton.leftAnchor, constant: -objectSpace),
        ]
    }
    
    var collectionViewConstraints: [NSLayoutConstraint] {
        return [
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: objectSpace),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -layoutMargins.bottom),
            collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: layoutMargins.left),
            collectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -layoutMargins.right)
        ]
    }
    
    var moreButtonConstraints: [NSLayoutConstraint] {
        return [
            showAllButton.firstBaselineAnchor.constraint(equalTo: titleLabel.firstBaselineAnchor),
            showAllButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -layoutMargins.right),
        ]
    }
    
    private func initialSetup() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        showAllButton.translatesAutoresizingMaskIntoConstraints = false
        
        showAllButton.setTitle("Show All", for: .normal)
        showAllButton.addTarget(self, action: #selector(didTapShowAllButton(sender:)), for: .touchUpInside)
        
        flowLayout.estimatedItemSize = CGSize(width: 100, height: 150)
        flowLayout.scrollDirection = .horizontal
        
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.cellIdentifier())
        
        contentView.addSubview(collectionView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(showAllButton)
    }
    
    private func initialConstraints() {
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(moreButtonConstraints)
        NSLayoutConstraint.activate(collectionViewConstraints)
    }
    
    func setup(with rowViewModel: RowViewModel) {
        guard let mediaCarouselViewModel = rowViewModel as? MediaCarouselViewModel else {
            fatalError("Unexpected view model sent to view")
        }
        carouselViewModel = mediaCarouselViewModel
        titleLabel.textColor = mediaCarouselViewModel.titleColor
        titleLabel.text = mediaCarouselViewModel.title
        collectionView.dataSource = mediaCarouselViewModel.carouselDataSource
        carouselViewModel?.rowViewModels.addObserver({ [weak self] rowViewModels in
            guard let self = self else { return }
            self.collectionView.reloadData()
            
            guard let sampleImageModel = rowViewModels.first as? ImageViewModel,
                let dimensionsData = sampleImageModel.dimensionsData.value else { return }
            
            self.heigthConstraint?.isActive = false
            self.heigthConstraint = self.collectionView.heightAnchor.constraint(equalToConstant: dimensionsData.height)
            self.heigthConstraint?.isActive = true
        })
    }
    
    @objc func didTapShowAllButton(sender: UIButton) {
        carouselViewModel?.viewModelTapped?()
    }
    
    override func prepareForReuse() {
        carouselViewModel?.rowViewModels.removeObserver()
        carouselViewModel = nil
    }
}
