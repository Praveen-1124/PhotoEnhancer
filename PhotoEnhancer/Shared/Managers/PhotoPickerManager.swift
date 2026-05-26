//
//  PhotoPickerManager.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 08/05/26.
//


import UIKit
import PhotosUI

final class PhotoPickerManager: NSObject {

    static let shared = PhotoPickerManager()
    private var completion: ((_ image: UIImage?, _ fileName: String?) -> Void)?

    private override init() {

    }

    func presentPicker(from viewController: UIViewController, completion: @escaping (UIImage?, String?) -> Void) {

        self.completion = completion

        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        viewController.present(picker, animated: true)
    }
}


extension PhotoPickerManager: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {

        picker.dismiss(animated: true)

        guard let result = results.first else { return }
        let provider = result.itemProvider

        guard provider.canLoadObject(ofClass: UIImage.self) else {
            completion?(nil, nil)
            return
        }

        let (fileName, extn) : (String?, String?) = {
            guard let assetId = result.assetIdentifier else {
                return (provider.suggestedName, nil)
            }

            let fetchResult = PHAsset.fetchAssets(
                withLocalIdentifiers: [assetId],
                options: nil
            )

            guard let asset = fetchResult.firstObject,
                  let resource = PHAssetResource.assetResources(for: asset).first else {
                return (provider.suggestedName, nil)
            }


            let utType: UTType
            if #available(iOS 26.0, *) {
                utType = resource.contentType
            } else {
                // Fallback on earlier versions
                utType = UTType(resource.uniformTypeIdentifier) ?? .png
            }
            return (resource.originalFilename, utType.preferredFilenameExtension.orEmpty)
        }()

        provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            DispatchQueue.main.async {
                self?.completion?(image as? UIImage, fileName.orEmpty)
            }
        }
    }
}
