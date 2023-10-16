//
//  ScenesAssembly.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import UIKit

final class ScenesAssembly {
    private var window: UIWindow?
    weak var viewModelFactory: AppViewModelFactory!
}

extension ScenesAssembly {
    func launchApp(with window: UIWindow?, cameraViewModel: CameraViewModel) {
        self.window = window
        window?.makeKeyAndVisible()
        
        showCameraScreen(with: cameraViewModel)
    }
    
    func showCameraScreen(with viewModel: CameraViewModel) {
        let vc = CameraViewController()
        vc.viewModel = viewModel
        window?.rootViewController = AppNavController(rootViewController: vc)
    }
    
    func showPreviewScreen(with viewModel: ImagePreviewViewModel?) {
        let vc = ImagePreviewViewController()
        vc.viewModel = viewModel
        
        let presentingVC = (topViewControlller() as? UINavigationController)
        presentingVC?.pushViewController(vc, animated: true)
    }
    
    func showGalleryScreen(with viewModel: GalleryViewModel?) {
        let vc = GalleryViewController()
        vc.viewModel = viewModel
        
        let presentingVC = (topViewControlller() as? UINavigationController)
        presentingVC?.pushViewController(vc, animated: true)
    }
    
    func closeTopVC() {
        let presentingVC = topViewControlller()
        presentingVC?.dismiss(animated: true)
    }
    
    func popChildVC() {
        guard let presentingVC = topViewControlller() as? UINavigationController else { return }
        if presentingVC.viewControllers.count > 1 {
            presentingVC.popViewController(animated: true)
        } else {
            closeTopVC()
        }
    }
}

fileprivate extension ScenesAssembly {
    func windowRootViewController() -> UIViewController? {
        guard let window, let rootVC = window.rootViewController else { return nil }
        
        return rootVC
    }
    
    func topViewControlller() -> UIViewController? {
        var rootVC = windowRootViewController()
        while let presentedViewController = rootVC?.presentedViewController {
            rootVC = presentedViewController
        }
        return rootVC
    }
}
