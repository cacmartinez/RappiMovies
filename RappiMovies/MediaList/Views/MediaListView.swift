import UIKit

class MediaListView: UIView {
    let collectionView: UICollectionView
    let collectionViewLayout = UICollectionViewFlowLayout()
    
    init() {
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
    
    func setupInitialState() {
        backgroundColor = AppColors.backgroundColor
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionViewLayout.estimatedItemSize = CGSize(width: 100, height: 100)
        
        addSubview(collectionView)
        
        collectionView.register(MediaListCell.self, forCellWithReuseIdentifier: MediaListCell.cellIdentifier())
    }
    
    func setupConstraints() {
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
}
