import UIKit

enum UploadFileType {
    typealias ImageExt = UIConstants.ImageExtension
    typealias DocumentExt = UIConstants.DocumentExtension
    
    case pdf
    case doc
    case xls
    case heic
    case image(ext: String)
    case none

    static func initialize(by type: String) -> UploadFileType {
        switch type.lowercased() {
        case DocumentExt.pdf:
            return .pdf
        case DocumentExt.doc, DocumentExt.docx:
            return .doc
        case DocumentExt.xls, DocumentExt.xlsx:
            return .xls
        case ImageExt.heic:
            return .heic
        case ImageExt.png, ImageExt.bmp, ImageExt.gif:
            return .image(ext: type)
        case ImageExt.jpeg, ImageExt.jpg:
            return .image(ext: ImageExt.jpeg)
        default:
            return .none
        }
    }

    init(fileName: String) {
        let components = fileName.components(separatedBy: Constants.Separators.dot)
        guard components.count > 1,
              let type = components.last else {
            self = .none
            return
        }

        self = UploadFileType.initialize(by: type)
    }

    var image: UIImage? {
        switch self {
        case .pdf:
            return UIImage(named: UIConstants.Image.pdfType)
        case .doc, .xls:
            return UIImage(named: UIConstants.Image.docType)
        case .image, .heic:
            return UIImage(named: UIConstants.Image.imageType)
        case .none:
            return nil
        }
    }

    var mimeType: String {
        switch self {
        case .pdf:
            return "application/pdf"
        case .doc:
            return "application/msword"
        case .xls:
            return "application/vnd.ms-excel"
        case .heic:
            return "application/heic"
        case .image(let ext):
            return "image/\(ext)"
        case .none:
            return ""
        }
    }
}
