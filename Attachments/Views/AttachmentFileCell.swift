import UIKit
import QuickLook

class AttachmentFileCell: UICollectionViewCell {

    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!

    public override func prepareForReuse() {
        super.prepareForReuse()
        previewImageView.image = nil
    }

    func set(with attachment: AttachmentFileModel) {
        fileNameLabel.text = attachment.fullName
        sizeLabel.text = AttachmentsUtils.sizeBytesToMBString(attachment.size)

        loadPreviewImage(attachment, for: previewImageView)
    }
}

extension AttachmentFileCell: AttachmentPreviewLoadType {}
