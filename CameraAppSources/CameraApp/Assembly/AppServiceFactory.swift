//
//  AppServiceFactory.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import Foundation

final class AppServiceFactory: DependencyFactory {
    func coreDataService() -> CoreDataService {
        return shared(CoreDataService())
    }

    func cameraManager() -> CameraManager {
        return shared(CameraManager())
    }

    func galleryManager() -> PhotoGalleryManager {
        return shared(PhotoGalleryManager())
    }
}
