import Foundation

class CategoriesListController: MediaListController {
    var categoriesViewModel: CategoriesListViewModel
    var viewModel: ListViewModel {
        return categoriesViewModel
    }
    var errorLoading: ((Error) -> Void)?
    var mediaTapped: ((ListModel) -> ())?
    var newValuesAdded: (([RowViewModel], [RowViewModel]) -> Void)?
    let moviesServiceController: MoviesServiceController
    
    func removeObservations() {
        moviesServiceController.removeListener(listener: self)
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
        
        moviesServiceController.addListener(listener: self)
        
        self.categoriesViewModel.categoriesCarrousels.forEach { category, viewModel in
            viewModel.carouselDataSource = ListControllerDataSourceHandler(listViewModel: viewModel)
            viewModel.viewModelTapped = { [weak self] in
                self?.mediaTapped?(category)
            }
        }
    }
    
    func updateImages(for category: MovieCategory, with movieModelsImageInfoMap: [(MovieAbstract, MediaImagesInfo)], urlProvider: ImageURLProvider) {
        guard let carrouselViewModel = categoriesViewModel.categoriesCarrousels[category] else {
            fatalError("Mismatch between categories in the view model and retrieved by service")
        }
        // TODO: add or remove images from original carousel, as the default of 20 cells might change in the future.
        
        // To reduce requests and because images in the carousel should have same size for ux purposes, we will only use the first image info and apply it to all other images in crousel
        let (firstMovie, firstImagesInfos) = movieModelsImageInfoMap[0]
        var firstImageInfo: MediaImagesInfo.ImageInfo? = nil
        if let posterPath = firstMovie.posterPath {
            firstImageInfo = firstImagesInfos.posters.first(where: { $0.filePath == posterPath })
        }
        zip(carrouselViewModel.rowViewModels.value, movieModelsImageInfoMap).forEach { imageViewModel, movieModelImageInfo in
            guard let imageViewModel = imageViewModel as? ImageViewModel else { fatalError("Unexpected model in list") }
            let (movieAbstract, _) = movieModelImageInfo
            imageViewModel.viewModelTapped = { [weak self] in
                self?.mediaTapped?(movieAbstract)
            }
            if let posterPath = movieAbstract.posterPath {
                imageViewModel.urlData.value = ImageViewModel.URLData(imagePath: posterPath, urlProvider: urlProvider)
                if let firstImageInfo = firstImageInfo {
                    imageViewModel.dimensionsData.value = ImageViewModel.DimensionsData(height: firstImageInfo.height, width: firstImageInfo.width, aspectRatio: firstImageInfo.aspectRatio)
                }
            }
        }
    }
}

extension CategoriesListController: MoviesServiceControllerListener {
    func didFinishFetchingMovies(fromCategory category: MovieCategory, page: Int, results: Result<MovieResultsInfo>) {
        switch results {
        case .Success(let configuration, let paginatedMoviesResult):
            let imageURLProvider = ImageURLProvider(configuration: configuration)
            updateImages(for: category, with: paginatedMoviesResult.results, urlProvider: imageURLProvider)
        case .Error(let error):
            errorLoading?(error)
        }
    }
    
    func moviesServiceControllerDidStartLoadingMovies() {
    }
    
    func moviesServiceControllerDidFinishLoadingMovies() {
    }
}