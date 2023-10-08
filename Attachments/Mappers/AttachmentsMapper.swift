import RealmSwift

class AttachmentsMapper {
    // MARK: - Typealias

    typealias UIModel = AttachmentFileModel
    typealias DataModel = FilePayload
    typealias Entity = FileEntity

    // MARK: - UIModel(s) to DataMadel(s)

    static func transform(models: [UIModel]) -> [DataModel] {
        models.map { transform(model: $0) }
    }

    static func transform(model: UIModel) -> DataModel {
        DataModel(id: model.id,
                  data: model.rawData ?? Data(),
                  status: model.status ?? .uploadPending,
                  type: UploadFileType.initialize(by: model.ext),
                  fileName: model.fullName,
                  size: model.size)
    }

    // MARK: - UIModel(s) to Entity(ies)

    static func toEntities(from models: [UIModel]) -> List<Entity> {
        let entities = List<Entity>()
        models.forEach { entities.append(toEntity(from: $0)) }

        return entities
    }

    static func toEntity(from model: UIModel) -> Entity {
        .init(id: model.id,
              status: model.status!.rawValue,
              accessUri: model.url,
              fileName: model.fullName,
              size: model.size)
    }

    // MARK: - DataModel(s) to Entity(ies)

    static func toEntities(from dataModels: [DataModel]) -> List<Entity> {
        let entities = List<Entity>()
        entities.append(objectsIn: dataModels.map { toEntity(from: $0) })

        return entities
    }
    
    static func toEntity(from dataModel: DataModel) -> Entity {
        Entity(id: dataModel.id,
               status: dataModel.status.rawValue,
               accessUri: dataModel.accessUri,
               fileName: dataModel.fileName,
               size: dataModel.size)
    }

    // MARK: - Entity(s) to UIModel(s)

    static func transform(entities: List<Entity>) -> [UIModel] {
        Array(entities).map { transform(entity: $0) }
    }

    static func transform(entity: Entity) -> UIModel {
        let attachment = UIModel()
        attachment.id = entity.id
        attachment.fullName = entity.fileName ?? .empty
        attachment.url = entity.accessUri ?? .empty
        attachment.status = .init(rawValue: entity.status.lowercasingFirstLetter()) ?? .uploadPending
        attachment.size = entity.size

        return attachment
    }

    // MARK: - As uploaded

    static func mapAsUploaded(from dataModel: DataModel, to entity: Entity) {
        guard dataModel.id == entity.id else { return }

        entity.status = AttachmentStatusModel.uploaded.rawValue
        entity.fileName = dataModel.fileName
        entity.size = dataModel.size
    }

}
