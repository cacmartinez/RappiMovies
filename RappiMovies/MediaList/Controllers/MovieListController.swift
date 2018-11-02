import Foundation

class MovieListController: MediaListController {
    let viewModel: MediaListViewModel = MediaListViewModel()
    private let moviesServiceController: MoviesServiceController
    private let category: MovieCategory
    private let dateFormatter: DateFormatter
    private var lastPageLoaded = 0
    private var totalPages = 0
    var mediaTapped: ((MediaListModel)->())?
    var errorLoading: ((Error)->Void)?
    var newValuesAdded: ((_ values: [MediaListRowViewModel], _ addedValues: [MediaListRowViewModel]) -> Void)?
    
    func removeObservations() {
        self.moviesServiceController.removeListener(listener: self)
    }
    
    func start() {
        DispatchQueue.main.async { [weak self] in
            self?.loadItemsOfPage(page: 1)
        }
    }
    
    func loadMore() {
        loadItemsOfPage(page: lastPageLoaded + 1)
    }
    
    private func loadItemsOfPage(page: Int) {
        if !viewModel.isLoading.value {
            moviesServiceController.fetchMoviePage(page, of: category)
        }
    }
    
    init(moviesServiceController: MoviesServiceController, category: MovieCategory, dateFormatter: DateFormatter) {
        self.moviesServiceController = moviesServiceController
        self.category = category
        self.dateFormatter = dateFormatter
        self.moviesServiceController.addListener(listener: self)
    }
    
    private func updateRowModels(with movieModelsImageInfoMap: [(MovieAbstract, MediaImagesInfo)], imageURLProvider: ImageURLProvider) {
        var newValues: [MediaListRowViewModel] = []
        for (movieModel, imagesInfo) in movieModelsImageInfoMap {
            let viewModel = MediaListRowViewModel(mediaListModel: movieModel, imagesInfo: imagesInfo, imageURLProvider: imageURLProvider, dateFormatter: dateFormatter)
            viewModel.viewModelTapped = { [weak self] in
                self?.mediaTapped?(movieModel)
            }
            newValues.append(viewModel)
        }
        viewModel.rowViewModels.value.append(contentsOf: newValues)
        newValuesAdded?(viewModel.rowViewModels.value, newValues)
    }
}

extension MovieListController: MoviesServiceControllerListener {
    func moviesServiceControllerDidStartLoadingMovies() {
        viewModel.isLoading.value = true
    }
    
    func moviesServiceControllerDidFinishLoadingMovies() {
        viewModel.isLoading.value = false
    }
    
    func didFinishFetchingMovies(fromCategory category: MovieCategory, page: Int, results: Result<MovieResultsInfo>) {
        switch results {
        case .Success(let configuration, let paginatedMoviesResult):
            totalPages = paginatedMoviesResult.paginationInfo.totalPages
            lastPageLoaded = page
            viewModel.canLoadMore = self.totalPages > page
            let imageURLProvider = ImageURLProvider(configuration: configuration)
            updateRowModels(with: paginatedMoviesResult.results, imageURLProvider: imageURLProvider)
        case .Error(let error):
            errorLoading?(error)
        }
    }
}
