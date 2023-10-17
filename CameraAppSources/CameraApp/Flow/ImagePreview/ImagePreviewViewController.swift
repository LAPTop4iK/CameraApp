//
//  ImagePreviewViewController.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import Combine
import UIKit

final class ImagePreviewViewController: AppViewController<ImagePreviewViewModel> {
    private var subscriptions = Set<AnyCancellable>()

    private lazy var filtersView: FilterSelectorView = {
        let view = FilterSelectorView(allowAddTag: true)
        view.onAddButtonTapped = { [weak self] in
            self?.showAddFilterAlert()
        }
        view.isHidden = true
        return view
    }()

    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let bottomView = BottomBarView()

    private lazy var saveButton: CustomButton = {
        let button = CustomButton(
            buttonShape: .circle,
            systemImageName: AppConstants.IconsName.save,
            addBackground: true
        )

        button.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        return button
    }()

    private lazy var tagButton: CustomButton = {
        let button = CustomButton(
            buttonShape: .circle,
            systemImageName: AppConstants.IconsName.tag,
            addBackground: true
        )

        button.addTarget(self, action: #selector(tagTapped), for: .touchUpInside)
        return button
    }()

    private lazy var closeButton: CustomButton = {
        let button = CustomButton(
            buttonShape: .circle,
            systemImageName: AppConstants.IconsName.close,
            addBackground: true
        )

        button.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupConstraints()
        bindViewModel()
    }
}

private extension ImagePreviewViewController {
    func bindViewModel() {
        viewModel?.$imageItem
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] imageItem in
                self?.setImageFrom(imageItem)
                self?.configureButtonsFor(imageItem)
            })
            .store(in: &subscriptions)

        viewModel?.$tags
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] tags in
                self?.filtersView.addFilters(filters: tags, activeTags: self?.viewModel?.activeTags ?? [])
            })
            .store(in: &subscriptions)
    }

    func setupViews() {
        view.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(bottomView)
        view.addSubview(filtersView)
    }

    func setupConstraints() {
        filtersView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(30)
            make.bottom.equalTo(bottomView.snp.top).offset(-30)
        }

        bottomView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    func configureButtonsFor(_ imageItem: ImageItem?) {
        if case .galleryImage = imageItem {
            bottomView.addButtons(tagButton, closeButton)
        } else {
            bottomView.addButtons(closeButton, tagButton, saveButton)
        }
    }

    func setImageFrom(_ imageItem: ImageItem?) {
        guard let imageItem = imageItem else { return }
        let image = imageItem.image

        let correctedImage = fixOrientation(img: image)

        let imageViewSize = imageView.frame.size
        let scale = min(imageViewSize.width / correctedImage.size.width, imageViewSize.height / correctedImage.size.height)
        let scaledImageWidth = correctedImage.size.width * scale
        let scaledImageHeight = correctedImage.size.height * scale
        let imageX = (imageViewSize.width - scaledImageWidth) / 2
        let imageY = (imageViewSize.height - scaledImageHeight) / 2
        let imageRect = CGRect(x: imageX, y: imageY, width: scaledImageWidth, height: scaledImageHeight)

        let imageLayer = CALayer()
        imageLayer.contents = correctedImage.cgImage
        imageLayer.frame = imageRect
        imageLayer.cornerRadius = 10
        imageLayer.masksToBounds = true

        imageView.layer.addSublayer(imageLayer)
    }

    func fixOrientation(img: UIImage) -> UIImage {
        if img.imageOrientation == .up {
            return img
        }

        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale)
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.draw(in: rect)

        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() ?? img
        UIGraphicsEndImageContext()

        return normalizedImage
    }
}

@objc
private extension ImagePreviewViewController {
    func dismissTapped() {
        viewModel?.activeTags = filtersView.selectedFilters
        viewModel?.dismiss()
    }

    func saveTapped() {
        viewModel?.activeTags = filtersView.selectedFilters
        viewModel?.saveToGallery()
    }

    func tagTapped() {
        filtersView.isHidden.toggle()
    }
}

private extension ImagePreviewViewController {
    func showAddFilterAlert() {
        let alertController = UIAlertController(title: "New Filter", message: "Enter the name of the new filter.", preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Filter name"
        }

        let confirmAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            if let filterName = alertController.textFields?.first?.text, !filterName.isEmpty, filterName != "+" {
                self?.viewModel?.saveTagWithName(filterName)
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }
}
