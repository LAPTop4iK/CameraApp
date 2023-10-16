//
//  AppNavigationController.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 16/10/2023.
//

import UIKit

class AppNavController: UINavigationController {
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
}

private extension AppNavController {
    func setupUI() {
        navigationBar.isHidden = true
    }
}
