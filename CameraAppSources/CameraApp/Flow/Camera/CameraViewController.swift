//
//  CameraViewController.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import AVFoundation
import SnapKit
import UIKit

class CameraViewController: AppViewController<CameraViewModel> {
    private lazy var shutterButton: CustomButton = {
        let button = CustomButton(buttonShape: .circle, image: AppResources.Images.mainPhoto)
        button.addTarget(self, action: #selector(shutterButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var galleryButton: CustomButton = {
        let button = CustomButton(buttonShape: .square, image: AppResources.Images.gallery)
        button.addTarget(self, action: #selector(galleryButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var flipCameraButton: CustomButton = {
        let button = CustomButton(buttonShape: .circle, systemImageName: AppConstants.IconsName.flip, addBackground: true, reversedColors: true)
        button.addTarget(self, action: #selector(flipCameraButtonTapped), for: .touchUpInside)
        return button
    }()

    var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel?.setupCamera(in: view)
        setupUI()

        NotificationCenter.default.addObserver(self, selector: #selector(orientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        viewModel?.startSession()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        viewModel?.stopSession()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}

private extension CameraViewController {
    func setupUI() {
        view.addSubview(shutterButton)

        shutterButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(20)
            make.width.equalTo(120)
        }

        view.addSubview(flipCameraButton)
        flipCameraButton.snp.makeConstraints { make in
            make.centerY.equalTo(shutterButton)
            make.leading.equalTo(shutterButton.snp.trailing).offset(30)
            make.width.height.equalTo(60)
        }

        view.addSubview(galleryButton)

        galleryButton.snp.makeConstraints { make in
            make.top.right.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.width.equalTo(72)
        }

        view.addSubview(previewImageView)
        previewImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

private extension CameraViewController {
    @objc func shutterButtonTapped() {
        viewModel?.captureImage(delegate: self)
    }

    @objc func galleryButtonTapped() {
        viewModel?.showGallery()
    }

    @objc func flipCameraButtonTapped() {
        viewModel?.flipCamera()
    }

    @objc func orientationChanged() {
        viewModel?.updateOrientation()
        adjustButtonImageOrientation()
    }

    func adjustButtonImageOrientation() {
        let rotateAngle: CGFloat
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            rotateAngle = .pi / 2
        case .landscapeRight:
            rotateAngle = -.pi / 2
        default:
            rotateAngle = 0.0
        }
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.shutterButton.transform = CGAffineTransform(rotationAngle: rotateAngle)
            self?.galleryButton.transform = CGAffineTransform(rotationAngle: rotateAngle)
            self?.flipCameraButton.transform = CGAffineTransform(rotationAngle: rotateAngle)
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            debugPrint(error.localizedDescription)
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData)
        else { return }

        viewModel?.showPreviewFor(image: image)
    }
}

extension CameraViewController: TransitioningDelegateSourceView {
    var sourceView: UIView? {
        return shutterButton
    }
}
