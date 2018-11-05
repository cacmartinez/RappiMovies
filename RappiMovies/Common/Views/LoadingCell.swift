import UIKit

class LoadingCell: UICollectionViewCell {
    private let loadingIndicator =  UIActivityIndicatorView(style: .gray)
    private let viewHeight: CGFloat = 60
    
    var loadingIndicatorConstraints: [NSLayoutConstraint] {
        let constraints = [
            loadingIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            loadingIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ]
        return constraints
    }
    
    var contentViewConstraints: [NSLayoutConstraint] {
        let constraints = [
            contentView.heightAnchor.constraint(equalToConstant: viewHeight)
        ]
        return constraints
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
        setupConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.style = .white
        contentView.addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate(loadingIndicatorConstraints)
        NSLayoutConstraint.activate(contentViewConstraints)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
    }
}
