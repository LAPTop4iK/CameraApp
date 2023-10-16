//
//  PhotoGalleryManager.swift
//  CameraApp
//
//  Created by Mikita Laptsionak on 12/10/2023.
//

import Photos
import UIKit

protocol PhotoGalleryManagerDelegate: AnyObject {
    func galleryDidUpdatePhotos()
}

class PhotoGalleryManager: NSObject, PHPhotoLibraryChangeObserver {
    weak var delegate: PhotoGalleryManagerDelegate?
    
    private let manager = PHImageManager.default()
    private let requestOptions: PHImageRequestOptions = {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat
        return requestOptions
    }()
    
    private let fetchOptions: PHFetchOptions = {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        return fetchOptions
    }()
    
    private static let size = CGSize(width: 300, height: 300)
    
    private var assetsFetchResult = PHFetchResult<PHAsset>()
    
    override init() {
        super.init()
        
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
}

extension PhotoGalleryManager {
    func fetchAllPhotos() async throws -> [GalleryImageModel] {
        assetsFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        var newPhotos: [GalleryImageModel] = []
        for i in 0 ..< assetsFetchResult.count {
            let asset = assetsFetchResult.object(at: i)
            let assetItem = try await loadImage(for: asset)
            if let image = assetItem.0, let identifier = assetItem.1 {
                let aspectRatio = CGFloat(image.size.width) / CGFloat(image.size.height)
                newPhotos.append(GalleryImageModel(image: image, isSelected: false, aspectRatio: aspectRatio, identifier: identifier))
            }
        }
        return newPhotos
    }
    
    func loadImage(for asset: PHAsset) async throws -> (UIImage?, String?) {
        return try await withCheckedThrowingContinuation { continuation in
            manager.requestImage(for: asset, targetSize: Self.size, contentMode: .aspectFill, options: requestOptions) { image, _ in
                continuation.resume(returning: (image, asset.localIdentifier))
            }
        }
    }
    
    func deleteSelectedAssets(at indexes: [Int]) async throws {
        let assetsToDelete = assetsFetchResult.objects(at: IndexSet(indexes))
        return try await performChangesWrapper {
            PHAssetChangeRequest.deleteAssets(assetsToDelete as NSFastEnumeration)
        }
    }
    
    func performChangesWrapper(_ changes: @escaping () -> Void) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            PHPhotoLibrary.shared().performChanges(changes) { _, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if let fetchResultChangeDetails = changeInstance.changeDetails(for: assetsFetchResult) {
            assetsFetchResult = fetchResultChangeDetails.fetchResultAfterChanges
            let insertedObjects = fetchResultChangeDetails.insertedObjects
            let removedObjects = fetchResultChangeDetails.removedObjects
            
            if !insertedObjects.isEmpty || !removedObjects.isEmpty {
                delegate?.galleryDidUpdatePhotos()
            }
        }
    }
}
