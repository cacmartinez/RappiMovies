import UIKit

protocol ConfigurableCell {
    func setup(with rowViewModel: RowViewModel)
    func setInitialConstraintWidthWithReferenceWidth(_ width: CGFloat)
}
