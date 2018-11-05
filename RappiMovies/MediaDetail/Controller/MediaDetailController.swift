import Foundation

class MovieDetailController: ListController {
    var viewModel: ListViewModel = MediaDetailViewModel()
    
    var errorLoading: ((Error) -> Void)?
    var listModelTapped: ((ListModel) -> ())?
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
            backdropViewModel.constraintPreference = .aspectRatioWithMaximumHeight(maximumHeight: 300)
            rowViewModels.append(backdropViewModel)
        }
        rowViewModels.append(TextViewModel(text: .regular(movieDetail.title)))
        rowViewModels.append(TextViewModel(text: .regular("original title: \(movieDetail.originalTitle)")))
        rowViewModels.append(TextViewModel(text: .regular("original language: \(movieDetail.originalLanguage)")))
        if let overview = movieDetail.overview {
            rowViewModels.append(TextViewModel(text: .regular(overview)))
        }
        let productionCompanies = movieDetail.productionCompanies.lazy.map({$0.name}).joined(separator: ",")
        rowViewModels.append(TextViewModel(text: .regular("production companies: \(productionCompanies)")))
        let productionCountries = movieDetail.productionCountries.lazy.map({$0.name}).joined(separator: ",")
        rowViewModels.append(TextViewModel(text: .regular("production countries: \(productionCountries)")))
        if let homepage = movieDetail.homepage {
            let homepageAttributed = NSMutableAttributedString(string: homepage.absoluteString)
            homepageAttributed.addAttribute(.link, value: homepage, range: NSRange(location: 0, length: homepage.absoluteString.utf16.count))
            rowViewModels.append(TextViewModel(text: .attributed(homepageAttributed)))
        }
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
