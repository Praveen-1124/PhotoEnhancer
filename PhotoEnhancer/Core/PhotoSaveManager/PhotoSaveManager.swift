//
//  PhotoSaveManager.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 25/05/26.
//

import UIKit
import Photos

final class PhotoSaveManager {

    static let shared = PhotoSaveManager()

    // MARK: Save Single Image

    func saveImage(_ image: UIImage, configuration: PhotoAlbumConfiguration, completion: @escaping (Result<Void, Error>) -> Void) {

        requestPhotoPermission { granted in

            guard granted else {
                completion(.failure(NSError(domain: "PhotoPermissionDenied", code: -1)))
                return
            }

            self.fetchOrCreateAlbum(named: configuration.albumName) { album in
                guard let album = album else {
                    completion(.failure(NSError(domain: "AlbumCreationFailed", code: -1)))
                    return
                }
                self.save(image: image, to: album, completion: completion)
            }
        }
    }

    // MARK: Save Multiple Images

    func saveImages(_ images: [UIImage], configuration: PhotoAlbumConfiguration, completion: @escaping (Result<Void, Error>) -> Void) {

        requestPhotoPermission { granted in
            guard granted else {
                completion(.failure(NSError(domain: "PhotoPermissionDenied", code: -1)))
                return
            }

            self.fetchOrCreateAlbum(named: configuration.albumName) { album in
                guard let album = album else {
                    completion(.failure(NSError(domain: "AlbumCreationFailed", code: -1)))
                    return
                }
                self.saveBatch(images: images, to: album, completion: completion)
            }
        }
    }
}

// MARK: - Permission

private extension PhotoSaveManager {

    func requestPhotoPermission(completion: @escaping (Bool) -> Void) {

        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        switch status {
        case .authorized, .limited:
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                DispatchQueue.main.async {
                    completion(newStatus == .authorized || newStatus == .limited)
                }
            }
        default:
            completion(false)
        }
    }
}

// MARK: - Album Handling

private extension PhotoSaveManager {

    func fetchOrCreateAlbum(named albumName: String, completion: @escaping (PHAssetCollection?) -> Void) {

        // Check existing
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: fetchOptions)
        if let existing = collection.firstObject {
            completion(existing)
            return
        }

        // Create album
        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let request = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            placeholder = request.placeholderForCreatedAssetCollection
        }) { success, error in

            guard success, let placeholderID = placeholder?.localIdentifier else {
                completion(nil)
                return
            }
            let result = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholderID], options: nil)
            completion(result.firstObject)
        }
    }
}

// MARK: - Save Image

private extension PhotoSaveManager {

    func save(image: UIImage, to album: PHAssetCollection, completion: @escaping (Result<Void, Error>) -> Void) {

        PHPhotoLibrary.shared().performChanges({

            let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)

            guard let placeholder = assetRequest.placeholderForCreatedAsset else {
                return
            }

            guard let albumRequest = PHAssetCollectionChangeRequest(for: album) else {
                return
            }

            albumRequest.addAssets([placeholder] as NSArray)

        }) { success, error in

            DispatchQueue.main.async {

                if success {
                    completion(.success(()))
                } else {
                    completion(.failure(error ?? NSError(domain: "SaveFailed", code: -1)))
                }
            }
        }
    }
}

// MARK: - Save Batch

private extension PhotoSaveManager {

    func saveBatch(images: [UIImage], to album: PHAssetCollection, completion: @escaping (Result<Void, Error>) -> Void) {

        PHPhotoLibrary.shared().performChanges({

            guard let albumRequest = PHAssetCollectionChangeRequest(for: album) else {
                return
            }

            var placeholders: [PHObjectPlaceholder] = []
            for image in images {
                let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                if let placeholder =
                    assetRequest.placeholderForCreatedAsset {
                    placeholders.append(placeholder)
                }
            }
            albumRequest.addAssets(placeholders as NSArray)

        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else {
                    completion(.failure(error ?? NSError(domain: "BatchSaveFailed", code: -1)))
                }
            }
        }
    }
}
