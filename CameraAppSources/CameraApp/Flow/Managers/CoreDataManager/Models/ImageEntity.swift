//
//  ImageEntity.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import CoreData

@objc(ImageEntity)
public class ImageEntity: NSManagedObject {

}

extension ImageEntity {
    @NSManaged public var galleryIdentifier: String
    @NSManaged public var tags: NSSet?
}

struct ImageModel {
    let galleryIdentifier: String
    let tagNames: [String]
}

extension ImageEntity: ConvertibleEntity {
    typealias ModelType = ImageModel
    
    func toModel() -> ImageModel? {
        guard let tagsSet = tags as? Set<TagEntity> else { return nil }
        let tagNames = tagsSet.compactMap { $0.name }
        return ImageModel(galleryIdentifier: galleryIdentifier, tagNames: tagNames)
    }
    
    func configure(with model: ImageModel) {
        self.galleryIdentifier = model.galleryIdentifier
        let tagEntities = model.tagNames.compactMap { tagName -> TagEntity? in
            let tagEntity = TagEntity(context: self.managedObjectContext!)
            tagEntity.name = tagName
            return tagEntity
        }
        self.tags = NSSet(array: tagEntities)
    }
}

extension ImageEntity {
    public func addToTags(_ value: TagEntity) {
        let items = self.mutableSetValue(forKey: "tags")
        items.add(value)
    }
    
    public func removeFromTags(_ value: TagEntity) {
        let items = self.mutableSetValue(forKey: "tags")
        items.remove(value)
    }
}
