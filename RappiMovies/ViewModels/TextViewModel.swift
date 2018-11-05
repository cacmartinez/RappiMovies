import Foundation

struct TextViewModel: RowViewModel {
    enum TextType {
        case regular(String)
        case attributed(NSAttributedString)
    }
    
    let text: TextType
    
    init(text: TextType) {
        self.text = text
    }
    
    var cellType: ConfigurableCollectionViewCell.Type {
        return TextCell.self
    }
}
