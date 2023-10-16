//
//  CameraViewModel.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import AVFoundation
import Combine
import Foundation
import UIKit

final class CameraViewModel: BaseViewModel {
    @Published var capturedImage: UIImage?
    
    var cameraManager: CameraManager?
    private var cancellables: Set<AnyCancellable> = []
    
    func setupCamera(in view: UIView) {
        cameraManager?.setupCamera(in: view)
    }
    
    func flipCamera() {
        cameraManager?.flipCamera()
    }
    
    func captureImage(delegate: AVCapturePhotoCaptureDelegate) {
        cameraManager?.captureImage(delegate: delegate)
    }
    
    func startSession() {
        cameraManager?.startSession()
    }
    
    func stopSession() {
        cameraManager?.stopSession()
    }
    
    func updateOrientation() {
        cameraManager?.updateOrientation()
    }
    
    func showPreviewFor(image: UIImage) {
        let imageItem = ImageItem.cameraImage(image)
        let viewModel = viewModelFactory?.previewViewModel(imageItem: imageItem)
        scenesAssembly?.showPreviewScreen(with: viewModel)
    }
    
    func showGallery() {
        let viewModel = viewModelFactory?.galleryViewModel()
        scenesAssembly?.showGalleryScreen(with: viewModel)
    }
}
