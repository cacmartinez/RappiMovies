import Foundation

class MovieListController: MediaListController {
    let viewModel: MediaListViewModel = MediaListViewModel()
    private let moviesService: MoviesService
    private let category: MovieCategory
    private let dateFormatter: DateFormatter
    var mediaTapped: ((MediaListModel)->())?
    var errorLoading: ((Error)->Void)?
    private var lastPageLoaded = 0
    private var totalPages = 0
    private let configurationController: TMDBConfigurationServiceController
    
    func removeObservations() {
        self.moviesService.removeListener(listener: self)
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
            viewModel.isLoading.value = true
            moviesService.fetchMoviePage(page, of: category)
        }
    }
    
    init(moviesService: MoviesService, category: MovieCategory, dateFormatter: DateFormatter, configurationController: TMDBConfigurationServiceController) {
        self.moviesService = moviesService
        self.category = category
        self.dateFormatter = dateFormatter
        self.configurationController = configurationController
        self.moviesService.addListener(listener: self)
    }
    
    private func updateRowModels(with movieModels: [MovieAbstract], imageURLProvider: ImageURLProvider) {
        var newValues: [MediaListRowViewModel] = []
        for movieModel in movieModels {
            let viewModel = MediaListRowViewModel(mediaListModel: movieModel, imageURLProvider: imageURLProvider, dateFormatter: dateFormatter)
            viewModel.viewModelTapped = { [weak self] in
                self?.mediaTapped?(movieModel)
            }
            newValues.append(viewModel)
        }
        viewModel.rowViewModels.value.append(contentsOf: newValues)
        viewModel.rowViewModelsAdded.value = newValues
    }
}

extension MovieListController: MoviesServiceListener {
    func didFinishFetchingMovies(fromCategory category: MovieCategory, page: Int, results: Result<PaginatedResult<[MovieAbstract]>>) {
        configurationController.configuration { [weak self] configurationResult in
            guard let self = self else { return }
            
            self.viewModel.isLoading.value = false
            switch (configurationResult, results) {
            case (.Success(let configuration),.Success(let paginatedResult)):
                self.totalPages = paginatedResult.paginationInfo.totalPages
                self.lastPageLoaded = page
                self.viewModel.canLoadMore = self.totalPages > page
                let imageURLProvider = ImageURLProvider(configuration: configuration)
                self.updateRowModels(with: paginatedResult.results, imageURLProvider: imageURLProvider)
            case (.Error(let error), _):
                self.errorLoading?(error)
            case (_, .Error(let error)):
                self.errorLoading?(error)
            }
        }
    }
}
