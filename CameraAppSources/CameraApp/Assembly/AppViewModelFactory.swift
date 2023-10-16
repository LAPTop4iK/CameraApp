//
//  AppViewModelFactory.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import Foundation
import UIKit

final class AppViewModelFactory: DependencyFactory {
    weak var serviceFactory: AppServiceFactory?
    weak var scenesAssembly: ScenesAssembly?
    
    fileprivate func setupProperties(for viewModel: BaseViewModel) {
        viewModel.viewModelFactory = self
        viewModel.coreDataService = serviceFactory?.coreDataService()
    }
}

extension AppViewModelFactory {
    func cameraViewModel() -> CameraViewModel {
        return scoped(CameraViewModel()) { [weak self] instance in
            self?.setupProperties(for: instance)
            instance.cameraManager = self?.serviceFactory?.cameraManager()
            instance.initialize()
        }
    }
    
    func previewViewModel(imageItem: ImageItem) -> ImagePreviewViewModel {
        return scoped(ImagePreviewViewModel(imageItem: imageItem)) { [weak self] instance in
            self?.setupProperties(for: instance)
            instance.initialize()
        }
    }
    
    func galleryViewModel() -> GalleryViewModel {
        return scoped(GalleryViewModel()) { [weak self] instance in
            self?.setupProperties(for: instance)
            instance.photoGalleryManager = self?.serviceFactory?.galleryManager()
            instance.initialize()
        }
    }
}
