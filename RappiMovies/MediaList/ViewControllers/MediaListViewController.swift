import UIKit

class MediaListViewController: UIViewController {
    let controller: MediaListController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppColors.backgroundColor
        // Do any additional setup after loading the view, typically from a nib.
    }

    init(controller: MediaListController) {
        self.controller = controller
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        self.controller = nil
        super.init(coder: aDecoder)
    }
    
    deinit {
        controller.removeObservations()
    }
}

