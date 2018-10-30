import UIKit

protocol RowViewModel {
    typealias ConfigurableCollectionViewCell = UICollectionViewCell & ConfigurableCell
    
    var cellType: ConfigurableCollectionViewCell.Type { get }
}
