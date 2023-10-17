//
//  TagEntity.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import CoreData

@objc(TagEntity)
public class TagEntity: NSManagedObject {}

public extension TagEntity {
    @NSManaged var name: String
    @NSManaged var images: NSSet?
}

struct TagModel {
    let name: String
}

extension TagEntity: ConvertibleEntity {
    typealias ModelType = TagModel

    func toModel() -> TagModel? {
        return TagModel(name: name)
    }

    func configure(with model: TagModel) {
        name = model.name
    }
}
