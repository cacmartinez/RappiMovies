import UIKit

class MediaDetailViewController: UIViewController {
    let controller: MediaListController!
    var controllerStarted = false
    let contentView = MediaListView()
    let loadingIndicatorView = UIActivityIndicatorView(style: .white)
    private var dataSourceHandler: ListControllerDataSourceHandler?
    
    init(detailController: MediaListController) {
        controller = detailController
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = AppColors.backgroundColor
        setupContentView()
        setupLoadingIndicatorView()
        setupContentViewConstraints()
        setupLoadingIndicatorConstraints()
    }
    
    @available(*, unavailable)
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        controller = nil
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        controller = nil
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSourceHandler = ListControllerDataSourceHandler(listViewModel: controller.viewModel)
        contentView.collectionView.dataSource = dataSourceHandler
        
        // If there are values in the beggining register their cells
        controller.viewModel.rowViewModels.value.forEach { rowViewModel in
            self.contentView.collectionView.register(rowViewModel.cellType, forCellWithReuseIdentifier:rowViewModel.cellType.cellIdentifier())
        }
        
        loadingIndicatorView.startAnimating()
        
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !controllerStarted {
            controller.start()
            controllerStarted = true
        }
    }
    
    private func setupBindings() {
        controller.viewModel.isLoading.addObserver(fireNow: false) { [weak self] isLoading in
            self?.contentView.isHidden = isLoading
            self?.loadingIndicatorView.isHidden = !isLoading
        }
        
        controller.viewModel.rowViewModels.addObserver(fireNow: false) { rowViewModels in
            rowViewModels.forEach { rowViewModel in
                self.contentView.collectionView.register(rowViewModel.cellType, forCellWithReuseIdentifier:rowViewModel.cellType.cellIdentifier())
            }
            self.contentView.collectionView.reloadData()
        }
    }
    
    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
    }
    
    private func setupLoadingIndicatorView() {
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadingIndicatorView)
    }
    
    private func setupContentViewConstraints() {
        contentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    private func setupLoadingIndicatorConstraints() {
        loadingIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loadingIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    deinit {
        controller.removeObservations()
    }
}
