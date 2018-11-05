import UIKit

protocol ListViewControllerDelegate: AnyObject {
    func didSelectListModel(_ model: ListModel)
}

class ListViewController: UIViewController {
    private var controller: ListController!
    let contentView: ListView
    private weak var delegate: ListViewControllerDelegate?
    private var delegateHandler: ListControllerDelegateHandler?
    private var dataSourceHandler: ListControllerDataSourceHandler?
    private var controllerStarted = false
    
    var loadingCellIndexPath: IndexPath {
        return IndexPath(row: controller.viewModel.rowViewModels.value.count, section: 0)
    }

    init(controller: ListController, delegate: ListViewControllerDelegate) {
        self.delegate = delegate
        contentView = ListView()
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
        setupContentView()
        setupContentViewConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        contentView = ListView()
        self.controller = nil
        super.init(coder: aDecoder)
        setupContentView()
        setupContentViewConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let paginatableController = controller as? PaginatedListController {
            delegateHandler = ListControllerDelegateHandler(listViewModel: controller.viewModel, paginationHandler: {
                if paginatableController.canLoadMore {
                    paginatableController.loadMore()
                }
            })
            
            contentView.collectionView.delegate = delegateHandler
        }
        dataSourceHandler = ListControllerDataSourceHandler(listViewModel: controller.viewModel)
        contentView.collectionView.dataSource = dataSourceHandler
        
        // If there are values in the beggining register their cells
        controller.viewModel.rowViewModels.value.forEach { rowViewModel in
            self.contentView.collectionView.register(rowViewModel.cellType, forCellWithReuseIdentifier:rowViewModel.cellType.cellIdentifier())
        }
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !controllerStarted {
            controllerStarted = true
            controller.start()
        }
    }
    
    private func setupBindings() {
        controller.errorLoading = { [weak self] error in
            guard let self = self else { return }
            if self.controller.viewModel.supportsLoadingIndicatorCell {
                UIView.performWithoutAnimation {
                    self.contentView.collectionView.deleteItems(at: [self.loadingCellIndexPath])
                }
            }
            // TODO: show error alert.
        }
        
        controller.newValuesAdded = { [weak self] values, addedValues in
            guard let self = self else { return }
            
            addedValues.forEach { rowViewModel in
                self.contentView.collectionView.register(rowViewModel.cellType, forCellWithReuseIdentifier:rowViewModel.cellType.cellIdentifier())
            }
            
            let oldRowValueCount = values.count - addedValues.count
            let oldLoadingCellIndexPath = IndexPath(row: oldRowValueCount, section: 0)
            let indexPaths = self.indexPathsFromIndices(of: addedValues, withRowOffset: oldRowValueCount)
            UIView.performWithoutAnimation {
                self.contentView.collectionView.performBatchUpdates({
                    if self.controller.viewModel.supportsLoadingIndicatorCell {
                        self.contentView.collectionView.deleteItems(at: [oldLoadingCellIndexPath])
                    }
                    self.contentView.collectionView.insertItems(at: indexPaths)
                }, completion: nil)
            }
        }
        
        controller.viewModel.isLoading.addObserver(fireNow: false) { [weak self] isLoading in
            guard let self = self else { return }
            if isLoading && self.controller.viewModel.supportsLoadingIndicatorCell {
                UIView.performWithoutAnimation {
                    self.contentView.collectionView.insertItems(at: [self.loadingCellIndexPath])
                }
            }
        }
        
        controller.listModelTapped = { [weak self] modelTapped in
            self?.delegate?.didSelectListModel(modelTapped)
        }
    }
    
    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
    }
    
    private func setupContentViewConstraints() {
        contentView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        contentView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        contentView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    private func indexPathsFromIndices(of elements: [RowViewModel], withRowOffset offset: Int) -> [IndexPath] {
        return elements.indices.map { index in
            return IndexPath(row: index + offset, section: 0)
        }
    }
    
    deinit {
        controller.removeObservations()
    }
}
