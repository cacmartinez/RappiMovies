import UIKit

class MediaListView: UIView {
    let collectionView: UICollectionView
    let collectionViewLayout = UICollectionViewFlowLayout()
    
    override init(frame: CGRect) {
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        super.init(frame: CGRect.zero)
        setupInitialState()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        super.init(coder: aDecoder)
        setupInitialState()
        setupConstraints()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let widthInsets = collectionView.contentInset.left + collectionView.contentInset.right
        collectionViewLayout.estimatedItemSize = CGSize(width: frame.width - widthInsets,
                                                        height: 100)
    }
    
    func setupInitialState() {
        backgroundColor = AppColors.backgroundColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        addSubview(collectionView)
        
        collectionView.register(MediaListCell.self, forCellWithReuseIdentifier: MediaListCell.cellIdentifier())
        collectionView.register(LoadingCell.self, forCellWithReuseIdentifier: LoadingCell.cellIdentifier())
    }
    
    func setupConstraints() {
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
}