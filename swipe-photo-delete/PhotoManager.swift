//
//  PhotoManager.swift
//  swipe-photo-delete
//
//  Created by Zachary Upstone on 29/03/2026.
//

import Photos
import SwiftUI
internal import Combine

class PhotoManager: ObservableObject {
    @Published var photos: [PHAsset] = []
    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined

    init() {
        checkAuthorization()
    }

    func checkAuthorization() {
        authorizationStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        if authorizationStatus == .authorized {
            fetchPhotos()
        }
    }

    func requestAuthorization() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
            DispatchQueue.main.async {
                self?.authorizationStatus = status
                if status == .authorized {
                    self?.fetchPhotos()
                }
            }
        }
    }

    func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        let results = PHAsset.fetchAssets(with: .image, options: fetchOptions)

        var fetchedPhotos: [PHAsset] = []
        results.enumerateObjects { asset, _, _ in
            fetchedPhotos.append(asset)
        }

        DispatchQueue.main.async {
            self.photos = fetchedPhotos
        }
    }

    func deletePhoto(_ asset: PHAsset, completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets([asset] as NSArray)
        }) { success, error in
            DispatchQueue.main.async {
                // Don't remove from photos array to avoid index issues
                completion(success)
            }
        }
    }

    func batchDeletePhotos(_ assets: [PHAsset], completion: @escaping (Int) -> Void) {
        guard !assets.isEmpty else {
            completion(0)
            return
        }

        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSArray)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    // Don't remove from photos array to avoid index issues
                    // The photos are deleted from the library, just not from our local array
                    completion(assets.count)
                } else {
                    completion(0)
                }
            }
        }
    }

    func loadImage(asset: PHAsset, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .highQualityFormat

        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
