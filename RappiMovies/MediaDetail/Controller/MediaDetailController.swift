import Foundation

class MovieDetailController: MediaListController {
    var viewModel: ListViewModel = MediaDetailViewModel()
    
    var errorLoading: ((Error) -> Void)?
    var mediaTapped: ((ListModel) -> ())?
    var newValuesAdded: (([RowViewModel], [RowViewModel]) -> Void)?
    private let moviesServiceController: MoviesServiceController
    private let movieId: Int
    
    func removeObservations() {
        moviesServiceController.removeMovieDetailListener(self)
    }
    
    init(movieId: Int, moviesServiceController: MoviesServiceController) {
        self.moviesServiceController = moviesServiceController
        self.movieId = movieId
        
        moviesServiceController.addMovieDetailListener(self)
    }
    
    func start() {
        moviesServiceController.fetchMovieDetailForMovieId(movieId)
    }
    
    func updateRowViewModels(with movieDetail: MovieDetail, configuration: TMDBConfiguration) {
        var rowViewModels = [RowViewModel]()
        if let backdropPath = movieDetail.imagePaths.backdrop,
            let imagesInfo = movieDetail.imagesInfo {
            let urlProvider = ImageURLProvider(configuration: configuration)
            let urlData = ImageViewModel.URLData(imagePath: backdropPath, urlProvider:urlProvider)
            var dimensionsData: ImageViewModel.DimensionsData? = nil
            if let backdropInfo = imagesInfo.backdrops.first(where: { $0.filePath == backdropPath }) {
                dimensionsData = ImageViewModel.DimensionsData(height: backdropInfo.height, width: backdropInfo.width, aspectRatio: backdropInfo.aspectRatio)
            }
            let backdropViewModel = ImageViewModel(dimensionsData: dimensionsData, urlData: urlData)
            rowViewModels.append(backdropViewModel)
        }
        rowViewModels.append(TextViewModel(text: .regular(movieDetail.title)))
        rowViewModels.append(TextViewModel(text: .regular("original title: \(movieDetail.originalTitle)")))
        let productionCompanies = movieDetail.productionCompanies.lazy.map({$0.name}).joined(separator: ",")
        rowViewModels.append(TextViewModel(text: .regular("production companies: \(productionCompanies)")))
        viewModel.rowViewModels.value = rowViewModels
    }
}

extension MovieDetailController: MoviesServiceControllerMovieDetailListener {
    func didFinishFetchingMovieDetail(with result: Result<(TMDBConfiguration, MovieDetail)>) {
        switch result {
        case .Success(let configuration, let movieDetail):
            updateRowViewModels(with: movieDetail, configuration: configuration)
        case .Error(let error):
            errorLoading?(error)
        }
    }
    
    func moviesServiceControllerDidStartLoadingMovieDetail() {
        viewModel.isLoading.value = true
    }
    
    func moviesServiceControllerDidFinishLoadingMovieDetail() {
        viewModel.isLoading.value = false
    }
    
    
}
