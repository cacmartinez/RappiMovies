import Foundation

class MovieListController: PaginatedListController {
    let viewModel: ListViewModel = MediaListViewModel()
    private let moviesServiceController: MoviesServiceController
    private let category: MovieCategory
    private let dateFormatter: DateFormatter
    private var lastPageLoaded = 0
    private var totalPages = 0
    var listModelTapped: ((ListModel)->())?
    var errorLoading: ((Error)->Void)?
    var newValuesAdded: ((_ values: [RowViewModel], _ addedValues: [RowViewModel]) -> Void)?
    var canLoadMore: Bool = false
    
    func removeObservations() {
        self.moviesServiceController.removeMovieListListener(self)
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
        self.moviesServiceController.addMovieListListener(self)
    }
    
    private func updateRowModels(with movieModelsImageInfoMap: [(MovieAbstract, MediaImagesInfo)], imageURLProvider: ImageURLProvider) {
        var newValues: [MediaListRowViewModel] = []
        for (movieModel, imagesInfo) in movieModelsImageInfoMap {
            let viewModel = MediaListRowViewModel(mediaListModel: movieModel, imagesInfo: imagesInfo, imageURLProvider: imageURLProvider, dateFormatter: dateFormatter)
            viewModel.viewModelTapped = { [weak self] in
                self?.listModelTapped?(movieModel)
            }
            newValues.append(viewModel)
        }
        viewModel.rowViewModels.value.append(contentsOf: newValues)
        newValuesAdded?(viewModel.rowViewModels.value, newValues)
    }
}

extension MovieListController: MoviesServiceControllerMovieListListener {
    func moviesServiceControllerDidStartLoadingMovieList() {
        if !viewModel.isLoading.value {
            viewModel.isLoading.value = true
        }
    }
    
    func moviesServiceControllerDidFinishLoadingMovieList() {
        if viewModel.isLoading.value {
            viewModel.isLoading.value = false
        }
    }
    
    func didFinishFetchingMovies(fromCategory category: MovieCategory, page: Int, results: Result<MovieResultsInfo>) {
        switch results {
        case .Success(let configuration, let paginatedMoviesResult):
            totalPages = paginatedMoviesResult.paginationInfo.totalPages
            lastPageLoaded = page
            canLoadMore = self.totalPages > page
            let imageURLProvider = ImageURLProvider(configuration: configuration)
            updateRowModels(with: paginatedMoviesResult.results, imageURLProvider: imageURLProvider)
        case .Error(let error):
            errorLoading?(error)
        }
    }
}
