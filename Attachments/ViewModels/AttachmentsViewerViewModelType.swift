import RxSwift
import RxCocoa

// MARK: - AttachmentsViewerViewModelInput

public struct AttachmentsViewerViewModelInput {
    private(set) var attachmentTapped: Driver<IndexPath>
    private(set) var showError: Driver<Error>
}

// MARK: - AttachmentsViewerViewModelOutput

public struct AttachmentsViewerViewModelOutput {
    private(set) var attachments: Driver<[AttachmentFileModel]>
    private(set) var attachmentData: Driver<(Data, Int)>
    private(set) var isLoading: Driver<Bool>
}

// MARK: - AttachmentsViewerViewModelType

public protocol AttachmentsViewerViewModelType {
    typealias Input = AttachmentsViewerViewModelInput
    typealias Output = AttachmentsViewerViewModelOutput

    mutating func transform(_ input: Input) -> Output
}
