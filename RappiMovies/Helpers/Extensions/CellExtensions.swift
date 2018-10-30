import UIKit

extension UICollectionViewCell {
    static func cellIdentifier() -> String {
        return String(describing: self)
    }
}
