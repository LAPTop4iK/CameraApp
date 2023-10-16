//
//  ImagePreviewViewModel.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import Foundation
import Photos
import UIKit

final class ImagePreviewViewModel: BaseViewModel {
    @Published var tags: [TagModel] = []
    
    var activeTags = [TagModel]()
    
    private let dataStoreManager = DataStoreManager()
    
    @Published var imageItem: ImageItem?
    
    init(imageItem: ImageItem) {
        self.imageItem = imageItem
    }
    
    override func initialize() {
        tags = dataStoreManager.fetchAllTags() ?? []
        
        if case let .galleryImage(image) = imageItem {
            activeTags = dataStoreManager.fetchTags(forImageIdentifier: image.identifier) ?? []
        }
    }
    
    func dismiss() {
        scenesAssembly?.popChildVC()
    }
    
    func saveToGallery() {
        guard let image = imageItem?.image else { return }
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    func saveTagWithName(_ name: String) {
        if let tag = dataStoreManager.createTag(withName: name) {
            tags.append(tag)
        }
    }

}

private extension ImagePreviewViewModel {
    @objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
                debugPrint(error.localizedDescription)
            } else {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                fetchOptions.fetchLimit = 1
                if let lastAsset = PHAsset.fetchAssets(with: .image, options: fetchOptions).firstObject {
                    let identifier = lastAsset.localIdentifier
                    
                    dataStoreManager.add(tags: activeTags, toImageIdentifier: identifier)
                    dismiss()
                }
            }
    }
}
