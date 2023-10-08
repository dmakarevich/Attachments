import UIKit
import RxSwift
import RxRelay
import RxDataSources
import QuickLook

class AttachmentsViewerViewController: BaseViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - Variables

    private var viewModel: AttachmentsViewerViewModelType!
    private var attachments: [AttachmentFileModel] = []
    private lazy var selectedAttachment = attachments.first!
    private let disposeBag = DisposeBag()
    private let sendError = PublishRelay<Error>()
    private let previewItemsSize: Int = 1

    // MARK: - Lazy variables

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView()
        loader.center = view.center
        view.addSubview(loader)

        return loader
    }()

    private lazy var defaultError: ResidentError = {
        .init(errorMessage: "SomethingWentWrong".localized)
    }()

    // MARK: - New instanse (init)

    static func newInstanse(viewModel: AttachmentsViewerViewModelType) -> AttachmentsViewerViewController {
        let vc = AttachmentsViewerViewController.newInstance(of: AttachmentsViewerViewController.self)
        vc.viewModel = viewModel

        return vc
    }

    // MARK: - Life cycle methods

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewController()
        bind()
    }

    // MARK: - Configures

    private func configureViewController() {
        title = "Documents".localized
        collectionView.register(cell: AttachmentFileCell.self)
    }

    private func bind() {
        guard var viewModel = viewModel else { return }

        let output = viewModel.transform(
            .init(attachmentTapped: collectionView.rx.itemSelected.asDriver(),
                  showError: sendError.asDriver(onErrorJustReturn: defaultError))
        )

        disposeBag.insert([
            output.isLoading
                .drive(onNext: { [weak self] isLoading in
                    guard let self = self else { return }
                    self.view.bringSubviewToFront(activityIndicator)
                    self.view.isUserInteractionEnabled = !isLoading
                    isLoading ? self.activityIndicator.startAnimating() : activityIndicator.stopAnimating()
                }),

            output.attachments
                .do(onNext: { [weak self] in self?.attachments = $0 })
                .drive(collectionView.rx.items(cellIdentifier: AttachmentFileCell.className)) { index, model, cell in
                    (cell as? AttachmentFileCell)?.set(with: model)
                },

            output
                .attachmentData
                .drive { [weak self] (data, index) in
                    self?.prepareAndOpen(with: data, at: index)
                }
        ])
    }

}

extension AttachmentsViewerViewController {

    // MARK: - Utils

    private func createTemporaryFile(from data: Data, withName name: String) -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        DispatchQueue.global(qos: .background).async {
            do {
                try data.write(to: url)
            } catch {
                DispatchQueue.main.async {
                    self.sendError.accept(error)
                }
            }
        }
    
        return url
    }

    private func prepareAndOpen(with data: Data, at index: Int) {
        guard !data.isEmpty else {
            return sendError.accept(defaultError)
        }

        activityIndicator.startAnimating()
        selectedAttachment = attachments[index]
        selectedAttachment.fileURL = nil
        selectedAttachment.fileURL = createTemporaryFile(
            from: data,
            withName: selectedAttachment.fullName
        )

        showDocument()
    }

    private func showDocument() {
        let previewVC = QLPreviewController()
        previewVC.dataSource = self
        previewVC.delegate = self
        previewVC.isEditing = false

        activityIndicator.stopAnimating()
        present(previewVC, animated: true)
    }

}

// MARK: - QLPreviewControllerDataSource

extension AttachmentsViewerViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        previewItemsSize
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        selectedAttachment
    }
}

// MARK: - QLPreviewControllerDelegate

extension AttachmentsViewerViewController: QLPreviewControllerDelegate {
    func previewController(_ controller: QLPreviewController, transitionViewFor item: QLPreviewItem) -> UIView? {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return nil }
        let cell = collectionView.cellForItem(at: indexPath) as? AttachmentFileCell
        
        return cell?.previewImageView
    }

    @available(iOS 13.0, *)
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        .disabled
    }
}
