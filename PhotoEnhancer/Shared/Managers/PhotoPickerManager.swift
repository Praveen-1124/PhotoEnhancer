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
    private var completion: ((UIImage?) -> Void)?

    private override init() {

    }

    func presentPicker(from viewController: UIViewController, completion: @escaping (UIImage?) -> Void) {

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

        guard let itemProvider = results.first?.itemProvider else {
            completion?(nil)
            return
        }

        guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
            completion?(nil)
            return
        }

        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            DispatchQueue.main.async {
                self?.completion?(image as? UIImage)
            }
        }
    }
}
