import UIKit

public protocol AttachmentPreviewLoadType {}

extension AttachmentPreviewLoadType {
    public func loadPreviewImage(_ attachment: AttachmentFileModel, for imageView: UIImageView) {
        let defaultImage = UIConstants.Attachment.baseDocumentIcon
        if attachment.fileType == .picture {
            imageView.attachImage(forCacheKey: attachment.url,
                                  withDefaultImage: defaultImage,
                                  useDefaultAsPlaceholder: false,
                                  asThumbnail: true)
        } else {
            imageView.image = defaultImage
        }
    }
}
