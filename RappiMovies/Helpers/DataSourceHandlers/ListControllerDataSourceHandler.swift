import UIKit

class ListControllerDataSourceHandler: NSObject, UICollectionViewDataSource {
    weak var listViewModel: ListViewModel?
    
    var loadingCellIndexPath: IndexPath {
        guard let listViewModel = listViewModel else { return IndexPath(row: Int.max, section: Int.max) }
        return IndexPath(row: listViewModel.rowViewModels.value.count, section: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let listViewModel = listViewModel else { return 0 }
        if !listViewModel.supportsLoadingIndicatorCell {
            return listViewModel.rowViewModels.value.count
        }
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
    
    init(listViewModel: ListViewModel) {
        self.listViewModel = listViewModel
    }
}
