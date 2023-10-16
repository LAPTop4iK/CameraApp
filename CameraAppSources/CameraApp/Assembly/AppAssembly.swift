//
//  AppAssembly.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import UIKit

final class AppAssembly {
    let viewModelFactory: AppViewModelFactory
    let scenesAssembly: ScenesAssembly
    let serviceFactory: AppServiceFactory

    init(with window: UIWindow?) {
        viewModelFactory = AppViewModelFactory()
        scenesAssembly = ScenesAssembly()
        serviceFactory = AppServiceFactory()

        viewModelFactory.serviceFactory = serviceFactory
        viewModelFactory.scenesAssembly = scenesAssembly

        scenesAssembly.launchApp(with: window, cameraViewModel: viewModelFactory.cameraViewModel())
    }
}
