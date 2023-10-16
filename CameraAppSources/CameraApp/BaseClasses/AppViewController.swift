//
//  AppViewController.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import Foundation

import UIKit

class AppViewController<ViewModelType>: UIViewController & ViewModelAssociated {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
}
