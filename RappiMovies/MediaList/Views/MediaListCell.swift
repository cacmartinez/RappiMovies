import UIKit
import SDWebImage

class MediaListCell: UICollectionViewCell, ConfigurableCell {
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let releaseDateLabel = UILabel()
    
    private var heightConstraintSet = false
    private let imageWidth: CGFloat = 80
    private let objectSpacing: CGFloat = 8
    private var imageHeightConstraint: NSLayoutConstraint?
    
    var posterImageConstraints: [NSLayoutConstraint] {
        return [
            posterImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: layoutMargins.left),
            posterImageView.widthAnchor.constraint(equalToConstant: imageWidth),
            posterImageView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: layoutMargins.top),
            posterImageView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -layoutMargins.bottom),
            posterImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ]
    }
    
    var titleLabelConstraints: [NSLayoutConstraint] {
        return [
            titleLabel.leadingAnchor.constraint(equalTo: posterImageView.trailingAnchor, constant: objectSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: layoutMargins.right),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: layoutMargins.top)
        ]
    }
    
    var releaseDateConstraints: [NSLayoutConstraint] {
        return [
            releaseDateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            releaseDateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            releaseDateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: objectSpacing),
            releaseDateLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ]
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
    
    public func setupViews() {
        contentView.backgroundColor = AppColors.listCellColor
        posterImageView.backgroundColor = .lightGray
        titleLabel.numberOfLines = 0
        
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        releaseDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(releaseDateLabel)
    }
    
    public func setupConstraints() {
        NSLayoutConstraint.activate(posterImageConstraints)
        NSLayoutConstraint.activate(titleLabelConstraints)
        NSLayoutConstraint.activate(releaseDateConstraints)
        
        contentView.widthAnchor.constraint(equalToConstant: frame.width).isActive = true
        self.imageHeightConstraint = posterImageView.widthAnchor.constraint(equalTo: posterImageView.heightAnchor)
        self.imageHeightConstraint?.isActive = true
    }
    
    func setup(with rowViewModel: RowViewModel) {
        guard let mediaListRowViewModel = rowViewModel as? MediaListRowViewModel else {
            fatalError("Wrong view model given to media list cell")
        }
        if let imageHeightConstraint = imageHeightConstraint {
            imageHeightConstraint.isActive = false
        }
        
        titleLabel.text = mediaListRowViewModel.title
        releaseDateLabel.text = "Release date: \(mediaListRowViewModel.releaseDate)"
        
        if let posterAspectRatio = mediaListRowViewModel.posterAspectRatio,
            let posterPath = mediaListRowViewModel.posterPath {
            self.imageHeightConstraint?.isActive = false
            self.imageHeightConstraint = posterImageView.widthAnchor.constraint(equalTo: posterImageView.heightAnchor, multiplier:posterAspectRatio)
            self.imageHeightConstraint?.isActive = true
            posterImageView.isHidden = false
            
            let posterURL = mediaListRowViewModel.imageURLProvider.url(for: .poster, withWidth: imageWidth, path: posterPath)
            posterImageView.sd_setImage(with: posterURL, completed: nil)
        }
    }
    
    override func prepareForReuse() {
        posterImageView.isHidden = true
    }
}
