import UIKit

class ListControllerDataSourceHandler: NSObject, UICollectionViewDataSource {
    weak var listViewModel: ListViewModel?
    
    var loadingCellIndexPath: IndexPath {
        guard let listViewModel = listViewModel else { return IndexPath(row: 0, section: 0) }
        return IndexPath(row: listViewModel.rowViewModels.value.count, section: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let listViewModel = listViewModel else { return 0 }
        let countOfLoadingCell = listViewModel.isLoading.value ? 1 : 0
        return listViewModel.rowViewModels.value.count + countOfLoadingCell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let listViewModel = listViewModel else { return UICollectionViewCell() }
        let cell: UICollectionViewCell
        switch indexPath {
        case loadingCellIndexPath:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: LoadingCell.cellIdentifier(), for: indexPath)
        default:
            let viewModel = listViewModel.rowViewModels.value[indexPath.item]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.cellType.cellIdentifier(), for: indexPath)
            if let cell = cell as? RowViewModel.ConfigurableCollectionViewCell {
                cell.setup(with: viewModel)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let listViewModel = listViewModel else { return }
        guard indexPath.row < listViewModel.rowViewModels.value.count else { return }
        let rowViewModel = listViewModel.rowViewModels.value[indexPath.row]
        if let tappableRowViewModel = rowViewModel as? ViewModelActionable {
            tappableRowViewModel.viewModelTapped?()
        }
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    init(listViewModel: ListViewModel) {
        self.listViewModel = listViewModel
    }
}
