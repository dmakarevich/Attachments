import RxSwift
import RxCocoa

// MARK: - AttachmentsViewerViewModel

public struct AttachmentsViewerViewModel: AttachmentsViewerViewModelType {
    private var attachments: [AttachmentFileModel]
    private let fileManager: FileManagerType
    private let networkManager: AttachmentsNetworkManagerType
    private let router: AttachmentsViewerType

    private let indicator = RxActivityIndicator()
    private let disposeBag = DisposeBag()

    init(
        with attachments: [AttachmentFileModel],
        fileManager: FileManagerType,
        networkManager: AttachmentsNetworkManagerType,
        router: AmenityNewReservationRouterType
    ) {
        self.attachments = attachments
        self.fileManager = fileManager
        self.networkManager = networkManager
        self.router = router
    }

    public mutating func transform(_ input: Input) -> Output {
        input.showError
            .drive { [self] error in
                router.showError(error)
            }
            .disposed(by: disposeBag)

        let loadedData = input.attachmentTapped.asObservable()
            .flatMap { [self] in
                getDataFor(attachment: attachments[$0.row])
                    .catchAndReturn(Data())
                    .trackActivity(indicator)
            }
            .observe(on: MainScheduler.instance)
            .withLatestFrom(input.attachmentTapped) { ($0, $1.row) }
            .asDriver(onErrorDo: router.showError)

        return .init(
            attachments: Driver.just(attachments),
            attachmentData: loadedData,
            isLoading: indicator.asDriver()
        )
    }

    // MARK: - Utility

    private func getDataFor(attachmentModel: AttachmentFileModel) -> Single<Data> {
        Single
            .just(attachmentModel)
            .flatMap { [self] attachment in
                if let attachmentData = fileManager.read(fileWith: attachment.url.sha256()) {
                    return .just(attachmentData)
                } else {
                    return download(attachment: attachment)
                }
            }
    }

    private func download(attachment: AttachmentFileModel) -> Single<Data> {
        networkManager
            .baseRequest(forEndpoint: .downloadFile(url: attachment.url))
            .do(onNext: { [self] response in
                fileManager.write(response.data, with: attachment.url.sha256())
            })
            .map { $0.data }
    }
}
