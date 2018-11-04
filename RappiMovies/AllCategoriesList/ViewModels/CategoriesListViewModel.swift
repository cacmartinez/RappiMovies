import Foundation

class CategoriesListViewModel: ListViewModel {
    let isLoading = Observable<Bool>(value: false)
    let categoriesCarrousels: [MovieCategory:MediaCarouselViewModel]
    let rowViewModels: Observable<[RowViewModel]>
    
    init(categoriesCarrousels: [MovieCategory:MediaCarouselViewModel]) {
        self.categoriesCarrousels = categoriesCarrousels
        rowViewModels = Observable(value: Array(categoriesCarrousels.values))
    }
}
