import UIKit

protocol MediaListViewControllerDelegate: AnyObject {
    func didSelectMedia(_ media: ListModel)
}

class MediaListViewController: UIViewController {
    private var controller: MediaListController!
    let contentView: MediaListView
    weak var delegate: MediaListViewControllerDelegate?
    
    var loadingCellIndexPath: IndexPath {
        return IndexPath(row: controller.viewModel.rowViewModels.value.count, section: 0)
    }

    init(controller: MediaListController, delegate: MediaListViewControllerDelegate) {
        self.delegate = delegate
        contentView = MediaListView()
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
        setupContentView()
        setupContentViewConstraints()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        contentView = MediaListView()
        self.controller = nil
        super.init(coder: aDecoder)
        setupContentView()
        setupContentViewConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        
        setupBindings()
        controller.start()
    }
    
    private func setupBindings() {
        controller.errorLoading = { [weak self] error in
            guard let self = self else { return }
            UIView.performWithoutAnimation {
                self.contentView.collectionView.deleteItems(at: [self.loadingCellIndexPath])
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
                    self.contentView.collectionView.deleteItems(at: [oldLoadingCellIndexPath])
                    self.contentView.collectionView.insertItems(at: indexPaths)
                }, completion: nil)
            }
        }
        
        controller.viewModel.isLoading.addObserver(fireNow: false) { [weak self] isLoading in
            guard let self = self else { return }
            if isLoading {
                UIView.performWithoutAnimation {
                    self.contentView.collectionView.insertItems(at: [self.loadingCellIndexPath])
                }
            }
        }
        
        controller.mediaTapped = { [weak self] mediaTapped in
            self?.delegate?.didSelectMedia(mediaTapped)
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

extension MediaListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let countOfLoadingCell = controller.viewModel.isLoading.value ? 1 : 0
        return controller.viewModel.rowViewModels.value.count + countOfLoadingCell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        switch indexPath {
        case loadingCellIndexPath:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCell.cellIdentifier(), for: indexPath)
        default:
            let viewModel = controller.viewModel.rowViewModels.value[indexPath.item]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.cellType.cellIdentifier(), for: indexPath)
            if let cell = cell as? RowViewModel.ConfigurableCollectionViewCell {
                cell.setup(with: viewModel)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row < controller.viewModel.rowViewModels.value.count else { return }
        let rowViewModel = controller.viewModel.rowViewModels.value[indexPath.row]
        if let tappableRowViewModel = rowViewModel as? ViewModelActionable {
            tappableRowViewModel.viewModelTapped?()
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}

extension MediaListViewController: UIScrollViewDelegate, UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let paginatableController = controller as? PaginatedMediaListController {
            if (isScrollViewAtBottom(scrollView) && paginatableController.canLoadMore) {
                paginatableController.loadMore()
            }
        }
    }
    
    func isScrollViewAtBottom(_ scrollView: UIScrollView) -> Bool {
        return scrollView.contentSize.height - scrollView.contentOffset.y <= scrollView.bounds.height
    }
}
