//
//  GalleryPhotoModel.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import UIKit

enum ImageItem {
    case cameraImage(UIImage)
    case galleryImage(GalleryImageModel)

    var image: UIImage {
        switch self {
        case let .cameraImage(image):
            return image
        case let .galleryImage(galleryItem):
            return galleryItem.image
        }
    }
}

struct GalleryImageModel {
    let image: UIImage
    var isSelected: Bool
    let aspectRatio: CGFloat
    let identifier: String
}
