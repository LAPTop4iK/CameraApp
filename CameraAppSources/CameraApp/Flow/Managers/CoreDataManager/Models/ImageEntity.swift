//
//  ImageEntity.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import CoreData

@objc(ImageEntity)
public class ImageEntity: NSManagedObject {}

public extension ImageEntity {
    @NSManaged var galleryIdentifier: String
    @NSManaged var tags: NSSet?
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
        galleryIdentifier = model.galleryIdentifier
        let tagEntities = model.tagNames.compactMap { tagName -> TagEntity? in
            guard let managedObjectContext = self.managedObjectContext else {
                return nil
            }
            
            let tagEntity = TagEntity(context: managedObjectContext)
            tagEntity.name = tagName
            return tagEntity
        }
        tags = NSSet(array: tagEntities)
    }
}

public extension ImageEntity {
    func addToTags(_ value: TagEntity) {
        let items = mutableSetValue(forKey: "tags")
        items.add(value)
    }

    func removeFromTags(_ value: TagEntity) {
        let items = mutableSetValue(forKey: "tags")
        items.remove(value)
    }
}
