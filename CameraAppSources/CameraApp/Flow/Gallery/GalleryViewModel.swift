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
    

    var photoGalleryManager: PhotoGalleryManager?

    override func initialize() {
        photoGalleryManager?.delegate = self
        Task {
            await loadPhotos()
        }
    }

    func showDetail(for indexPath: IndexPath) {
        let item = ImageItem.galleryImage(photos[indexPath.item])
        let viewModel = viewModelFactory?.previewViewModel(imageItem: item)
        scenesAssembly?.showPreviewScreen(with: viewModel)
    }

    func backToCamera() {
        scenesAssembly?.popChildVC()
    }

    func loadPhotos() async {
        do {
            photos = try await photoGalleryManager?.fetchAllPhotos() ?? []
        } catch {
            debugPrint("Error loading photos: \(error)")
        }
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
