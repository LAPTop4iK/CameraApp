//
//  UIViewController+ViewModel.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import UIKit

private enum AssociatedKeys {
    static var viewModel = 700
}

protocol ViewModelAssociated where Self: UIViewController {
    associatedtype ViewModelType

    var viewModel: ViewModelType? { get set }
}

extension ViewModelAssociated {
    var viewModel: ViewModelType? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.viewModel) as? ViewModelType
        } set {
            if let value = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.viewModel, value, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}
