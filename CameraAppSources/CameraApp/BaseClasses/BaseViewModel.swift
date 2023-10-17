//
//  BaseViewModel.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import Foundation

enum ViewModelState: Equatable {
    static func == (lhs: ViewModelState, rhs: ViewModelState) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial):
            return true
        case (.loading, .loading):
            return true
        case (.refreshing, .refreshing):
            return true
        case (.loaded, .loaded):
            return true
        case (.error, .error):
            return true
        case (.emptyData, .emptyData):
            return true
        default:
            return false
        }
    }

    case initial
    case loading
    case refreshing
    case loaded
    case error(Error)
    case emptyData
}

class BaseViewModel: NSObject, ObservableObject {
    @Published var state: ViewModelState = .initial

    weak var viewModelFactory: AppViewModelFactory?
    weak var coreDataService: CoreDataService?

    var scenesAssembly: ScenesAssembly? {
        return viewModelFactory?.scenesAssembly
    }

    func initialize() {}
}
