//
//  GalleryViewModel.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import Combine
import Photos
import UIKit

class GalleryViewModel: BaseViewModel {
    @Published private(set) var photos = [GalleryImageModel]()
    @Published private(set) var isEditMode = false

    @Published var tags: [TagModel] = []
    var activeTags = [TagModel]()
    private let dataStoreManager = DataStoreManager()

    private var isFetchingPhotos = false
    var photoGalleryManager: PhotoGalleryManager?

    override func initialize() {
        photoGalleryManager?.delegate = self
        Task {
            await loadPhotos()
        }
        tags = dataStoreManager.fetchAllTags() ?? []
    }

    func showDetail(for indexPath: IndexPath) {
        let item = ImageItem.galleryImage(photos[indexPath.item])
        let viewModel = viewModelFactory?.previewViewModel(imageItem: item)
        scenesAssembly?.showPreviewScreen(with: viewModel)
    }

    func backToCamera() {
        scenesAssembly?.popChildVC()
    }

    func filterPhotosForTag(_ tag: TagModel) {
        let identifiers = dataStoreManager.fetchImages(withTag: tag)?.compactMap { $0.galleryIdentifier } ?? []
        Task {
            await loadPhotoWithIds(identifiers)
        }
    }

    func loadPhotoWithIds(_ ids: [String]) async {
        guard !isFetchingPhotos else { return }
        isFetchingPhotos = true
        do {
            photos = try await photoGalleryManager?.fetchPhotos(withIdentifiers: ids) ?? []
        } catch {
            debugPrint("Error loading photos: \(error)")
        }
        isFetchingPhotos = false
    }

    func loadPhotos() async {
        guard !isFetchingPhotos else { return }
        isFetchingPhotos = true
        do {
            photos = try await photoGalleryManager?.fetchAllPhotos() ?? []
        } catch {
            debugPrint("Error loading photos: \(error)")
        }
        isFetchingPhotos = false
    }

    // MARK: - Photo Selection

    func updateSelection(for index: Int) {
        if !isEditMode {
            isEditMode = true
        }

        photos[index].isSelected.toggle()
    }

    func deselectAll() {
        photos.enumerated().forEach { i, _ in
            photos[i].isSelected = false
        }

        isEditMode = false
    }

    // MARK: - Photo Deletion

    func deleteSelectedPhotos() {
        Task {
            await deleteSelected()
        }
    }

    private func deleteSelected() async {
        let indexes = photos.enumerated().compactMap { $0.element.isSelected ? $0.offset : nil }
        guard !indexes.isEmpty else { return }

        do {
            try await photoGalleryManager?.deleteSelectedAssets(at: indexes)
            photos = try await photoGalleryManager?.fetchAllPhotos() ?? []
        } catch {
            debugPrint("Failed to delete assets: \(error)")
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension GalleryViewModel: PhotoGalleryManagerDelegate {
    func galleryDidUpdatePhotos() {
        Task {
            await loadPhotos()
        }
    }
}
