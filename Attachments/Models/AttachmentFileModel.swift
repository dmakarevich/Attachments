import Foundation
import QuickLook

// MARK: - AttachmentFileModel

public class AttachmentFileModel: NSObject {
    var id: String = UUID.generateID()
    var size: Double = 0.0
    var url: String = ""
    var fileURL: URL?
    var rawData: Data?
    var status: AttachmentStatusModel?
    var fullName: String = "" {
        didSet {
            let nameComponents = fullName.components(separatedBy: Constants.Separators.dot)
            if let name = nameComponents.first { self.name = name }
            if nameComponents.count > 1,
               let ext = nameComponents.last { self.ext = ext }
        }
    }

    private(set) var name: String = ""
    private(set) var ext: String = ""

    var fileType: AttachmentFileType {
        .init(ext: ext)
    }
}

// MARK: - QLPreviewItem

extension AttachmentFileModel: QLPreviewItem {
    public var previewItemTitle: String? {
        fullName
     }

    public var previewItemURL: URL? {
        fileURL
    }
}

// MARK: - AttachmentStatusModel & AttachmentFileType

extension AttachmentFileModel {
    enum AttachmentFileType: String {
        case picture
        case pdf
        case file

        init(ext: String) {
            switch ext.lowercased(){
            case "jpg", "png", "jpeg", "gif", "heic", "bmp":
                self = .picture
            case "pdf":
                self = .pdf
            default:
                self = .file
            }
        }
    }
}

enum AttachmentStatusModel: String {
    case uploaded = "Uploaded"
    case uploadInProgress = "UploadInProgress"
    case uploadPending = "UploadPending"
}
