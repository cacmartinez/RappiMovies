import Foundation

class CategoriesListController: ListController {
    var categoriesViewModel: CategoriesListViewModel
    var viewModel: ListViewModel {
        return categoriesViewModel
    }
    var errorLoading: ((Error) -> Void)?
    var listModelTapped: ((ListModel) -> ())?
    var newValuesAdded: (([RowViewModel], [RowViewModel]) -> Void)?
    let moviesServiceController: MoviesServiceController
    
    func removeObservations() {
        moviesServiceController.removeMovieListListener(self)
    }
    
    func start() {
        if !viewModel.isLoading.value {
            MovieCategory.allCases.forEach { moviesServiceController.fetchMoviePage(1, of: $0, optimisticDimensions: true) }
        }
    }
    
    init(moviesServiceController: MoviesServiceController) {
        self.moviesServiceController = moviesServiceController
        
        let categoriesCarousels: [MovieCategory:MediaCarouselViewModel] =
            MovieCategory.allCases.reduce(into: [:], { categoriesCarousels, category in
                let dimensionData = ImageViewModel.DimensionsData(height: 150, width: 100, aspectRatio:100.0/150.0)
                categoriesCarousels[category] = MediaCarouselViewModel(title: category.rawValue, numberOfElements: 20, dimensionData: dimensionData)
            })
        
        self.categoriesViewModel = CategoriesListViewModel(categoriesCarrousels: categoriesCarousels)
        
        moviesServiceController.addMovieListListener(self)
        
        self.categoriesViewModel.categoriesCarrousels.forEach { category, viewModel in
            viewModel.carouselDataSource = ListControllerDataSourceHandler(listViewModel: viewModel)
            viewModel.viewModelTapped = { [weak self] in
                self?.listModelTapped?(category)
            }
        }
    }
    
    func updateImages(for category: MovieCategory, with movieModelsImageInfoMap: [(MovieAbstract, MediaImagesInfo)], urlProvider: ImageURLProvider) {
        guard let carrouselViewModel = categoriesViewModel.categoriesCarrousels[category] else {
            fatalError("Mismatch between categories in the view model and retrieved by service")
        }
        // TODO: add or remove images from original carousel, as the default of 20 cells might change in the future.
        zip(carrouselViewModel.rowViewModels.value, movieModelsImageInfoMap).forEach { imageViewModel, movieModelImageInfo in
            guard let imageViewModel = imageViewModel as? ImageViewModel else { fatalError("Unexpected model in list") }
            let (movieAbstract, _) = movieModelImageInfo
            imageViewModel.viewModelTapped = { [weak self] in
                self?.listModelTapped?(movieAbstract)
            }
            if let posterPath = movieAbstract.posterPath {
                imageViewModel.urlData.value = ImageViewModel.URLData(imagePath: posterPath, urlProvider: urlProvider)
            }
        }
    }
}

extension CategoriesListController: MoviesServiceControllerMovieListListener {
    func didFinishFetchingMovies(fromCategory category: MovieCategory, page: Int, results: Result<MovieResultsInfo>) {
        switch results {
        case .Success(let configuration, let paginatedMoviesResult):
            let imageURLProvider = ImageURLProvider(configuration: configuration)
            updateImages(for: category, with: paginatedMoviesResult.results, urlProvider: imageURLProvider)
        case .Error(let error):
            errorLoading?(error)
        }
    }
    
    func moviesServiceControllerDidStartLoadingMovieList() {
    }
    
    func moviesServiceControllerDidFinishLoadingMovieList() {
    }
}
