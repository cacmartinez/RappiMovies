import UIKit

class MediaListViewController: UIViewController {
    private var controller: MediaListController!
    let contentView: MediaListView

    init(controller: MediaListController) {
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
            guard let _ = self else { return }
            // TODO: show error alert.
        }
        
        controller.newValuesAdded = { [weak self] values, addedValues in
            guard let self = self else { return }
            let oldRowValueCount = values.count - addedValues.count
            let indexPaths = self.indexPathsFromIndices(of: addedValues, withRowOffset: oldRowValueCount)
            self.contentView.collectionView.insertItems(at: indexPaths)
        }
        
        controller.viewModel.isLoading.addObserver(fireNow: false) { [weak self] isLoading in
            guard let _ = self else { return }
            // TODO: Handle loading view.
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
    
    private func indexPathsFromIndices(of elements: [MediaListRowViewModel], withRowOffset offset: Int) -> [IndexPath] {
        return elements.indices.map { index in
            return IndexPath(row: index + offset, section: 0)
        }
    }
    
    deinit {
        controller.removeObservations()
    }
}

extension MediaListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return controller.viewModel.rowViewModels.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let viewModel = controller.viewModel.rowViewModels.value[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.cellType.cellIdentifier(), for: indexPath) as! RowViewModel.ConfigurableCollectionViewCell
        cell.setup(with: viewModel)
        cell.setInitialConstraintWidthWithReferenceWidth(collectionView.frame.width)
        return cell
    }
}

