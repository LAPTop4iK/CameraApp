//
//  CameraManager.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import AVFoundation
import Combine
import UIKit

final class CameraManager {
    private var captureSession: AVCaptureSession?
    private var stillImageOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?

    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.startRunning()
        }
    }

    func stopSession() {
        DispatchQueue.main.async {
            self.captureSession?.stopRunning()
        }
    }

    func flipCamera() {
        guard let currentInput = captureSession?.inputs.first as? AVCaptureDeviceInput else { return }
        guard let newCameraDevice = (currentInput.device.position == .front ? getBackCamera() : getFrontCamera()) else { return }

        do {
            let newInput = try AVCaptureDeviceInput(device: newCameraDevice)
            captureSession?.beginConfiguration()
            captureSession?.removeInput(currentInput)
            if captureSession?.canAddInput(newInput) == true {
                captureSession?.addInput(newInput)
            } else {
                captureSession?.addInput(currentInput)
            }
            captureSession?.commitConfiguration()
        } catch {
            debugPrint(error.localizedDescription)
        }
    }

    func captureImage(delegate: AVCapturePhotoCaptureDelegate) {
        let settings = AVCapturePhotoSettings()
        stillImageOutput?.capturePhoto(with: settings, delegate: delegate)
    }

    func setupCamera(in view: UIView) {
        captureSession = AVCaptureSession()

        guard let captureSession = captureSession,
              let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice)
        else {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        let photoOutput = AVCapturePhotoOutput()
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
            stillImageOutput = photoOutput
        } else {
            return
        }

        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.frame = view.layer.bounds
        videoPreviewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoPreviewLayer)
        previewLayer = videoPreviewLayer
    }

    func updateOrientation() {
        let newVideoOrientation: AVCaptureVideoOrientation

        if let orientation = AVCaptureVideoOrientation(deviceOrientation: UIDevice.current.orientation) {
            newVideoOrientation = orientation
        } else {
            newVideoOrientation = .portrait
        }

        if let captureSessionConnection = captureSession?.connections.first, captureSessionConnection.isVideoOrientationSupported {
            captureSessionConnection.videoOrientation = newVideoOrientation
        }
    }
}

private extension CameraManager {
    func getFrontCamera() -> AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
    }

    func getBackCamera() -> AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    }
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
}
