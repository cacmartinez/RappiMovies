import UIKit

class MediaListCell: UICollectionViewCell, ConfigurableCell {
    private let posterImageView = UIImageView()
    private let titleLabel = UILabel()
    private let expirationDateLabel = UILabel()
    private var widthConstraintSet = false
    
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
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        expirationDateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(posterImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(expirationDateLabel)
    }
    
    func setInitialConstraintWidthWithReferenceWidth(_ width: CGFloat) {
        if !widthConstraintSet {
            let marginWidth = self.layoutMargins.left + self.layoutMargins.right
            contentView.widthAnchor.constraint(equalToConstant: width - marginWidth).isActive = true
            widthConstraintSet = true
        }
    }
    
    public func setupConstraints() {
    }
    
    func setup(with rowViewModel: RowViewModel) {
        guard let mediaListRowViewModel = rowViewModel as? MediaListRowViewModel else {
            fatalError("Wrong view model given to media list cell")
        }
    }
}
