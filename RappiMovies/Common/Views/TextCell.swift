import UIKit

class TextCell: UICollectionViewCell, ConfigurableCell {
    let textLabel = UILabel()
    var widthConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
        setupConstraints()
        
        let layoutMarginsWidth = layoutMargins.left + layoutMargins.right
        widthConstraint = textLabel.widthAnchor.constraint(equalToConstant: frame.width - layoutMarginsWidth)
        widthConstraint!.isActive = true
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func initialSetup() {
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.numberOfLines = 0
        contentView.backgroundColor = AppColors.listCellColor
        contentView.addSubview(textLabel)
    }
    
    private func setupConstraints() {
        textLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: layoutMargins.top).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -layoutMargins.bottom).isActive = true
        textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: layoutMargins.left).isActive = true
        textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -layoutMargins.right).isActive = true
    }
    
    func setup(with rowViewModel: RowViewModel) {
        guard let textViewModel = rowViewModel as? TextViewModel else {
            fatalError("received unexpected view model")
        }
        switch textViewModel.text {
        case .regular(let text):
            textLabel.text = text
        case .attributed(let attributedString):
            textLabel.attributedText = attributedString
        }
    }
    
    override func prepareForReuse() {
        textLabel.text = nil
        textLabel.attributedText = nil
    }
}
