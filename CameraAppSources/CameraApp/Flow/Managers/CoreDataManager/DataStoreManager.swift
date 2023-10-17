//
//  DataStoreManager.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import CoreData

protocol ConvertibleEntity where Self: NSManagedObject {
    associatedtype ModelType
    func toModel() -> ModelType?
    func configure(with model: ModelType)
}

class PersistentContainerWrapper {
    static let shared = PersistentContainerWrapper()

    private(set) var initializationError: DataStoreErrors?

    var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CameraApp")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                debugPrint("PersistentContainer: \(error)")
                shared.initializationError = .persistentContainerError
            }
        })
        return container
    }()

    private init() {}
}

enum DataStoreErrors: Error {
    case persistentContainerError
}

class DataStoreManager {
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistentContainerWrapper.shared.persistentContainer.viewContext) {
        self.context = context
    }
}

extension DataStoreManager {
    func fetchAllTags() -> [TagModel]? {
        guard let request = TagEntity.fetchRequest() as? NSFetchRequest<TagEntity>,
              let tagEntities = try? context.fetch(request) else { return nil }
        return tagEntities.compactMap { $0.toModel() }
    }

    func fetchTags(forImageIdentifier identifier: String) -> [TagModel]? {
        guard let request = ImageEntity.fetchRequest() as? NSFetchRequest<ImageEntity> else { return nil }
        request.predicate = NSPredicate(format: "galleryIdentifier == %@", identifier)
        guard let image = try? context.fetch(request).first, let tagsSet = image.tags as? Set<TagEntity> else { return nil }
        return tagsSet.compactMap { $0.toModel() }
    }

    func remove(tags: [TagModel], fromImageIdentifier identifier: String) {
        guard let request = ImageEntity.fetchRequest() as? NSFetchRequest<ImageEntity> else { return }
        request.predicate = NSPredicate(format: "galleryIdentifier == %@", identifier)
        if let image = try? context.fetch(request).first {
            for tagModel in tags {
                if let tagEntity = findTagEntity(byName: tagModel.name) {
                    image.removeFromTags(tagEntity)
                }
            }
            saveContext()
        }
    }

    func createTag(withName name: String) -> TagModel? {
        let tagEntity = TagEntity(context: context)
        tagEntity.name = name
        saveContext()
        return tagEntity.toModel()
    }

    func add(tags: [TagModel], toImageIdentifier identifier: String) {
        guard let request = ImageEntity.fetchRequest() as? NSFetchRequest<ImageEntity> else { return }
        request.predicate = NSPredicate(format: "galleryIdentifier == %@", identifier)

        let image = try? context.fetch(request).first

        if image == nil {
            // If the image was not found, create a new one
            let newImage = ImageEntity(context: context)
            newImage.galleryIdentifier = identifier
            for tagModel in tags {
                let tagEntity = findOrCreateTagEntity(byName: tagModel.name)
                newImage.addToTags(tagEntity)
            }
        } else if let existingImage = image {
            // If the image exists, remove all existing tags
            if let existingTags = existingImage.tags as? Set<TagEntity> {
                for tag in existingTags {
                    existingImage.removeFromTags(tag)
                }
            }

            // Now, add the new tags
            for tagModel in tags {
                let tagEntity = findOrCreateTagEntity(byName: tagModel.name)
                existingImage.addToTags(tagEntity)
            }
        }

        saveContext()
    }

    func fetchImages(withTag tag: TagModel) -> [ImageModel]? {
        guard let tagEntity = findTagEntity(byName: tag.name), let imagesSet = tagEntity.images as? Set<ImageEntity> else { return nil }
        return imagesSet.compactMap { $0.toModel() }
    }

    private func findTagEntity(byName name: String) -> TagEntity? {
        guard let request = TagEntity.fetchRequest() as? NSFetchRequest<TagEntity> else { return nil }
        request.predicate = NSPredicate(format: "name == %@", name)
        return try? context.fetch(request).first
    }

    private func findOrCreateTagEntity(byName name: String) -> TagEntity {
        if let tag = findTagEntity(byName: name) {
            return tag
        }

        let tag = TagEntity(context: context)
        tag.name = name
        return tag
    }

    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                debugPrint("Failed saving context: \(error)")
            }
        }
    }
}
