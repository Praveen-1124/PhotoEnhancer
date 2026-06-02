//
//  HomeViewController.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 13/05/26.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }

    deinit {

    }

    private func setupUI() {
        self.title = "Photo Enhancer"
    }

    @IBAction func didClickFeatureButton(_ sender: FeatureButton) {

        let feature = Feature.allCases[sender.tag]
        if feature == .camera {
            moveToCameraVC(feature: feature)
        } else {
            showPickerView(feature: feature)
        }
    }

    private func showPickerView(feature: Feature) {

        PhotoPickerManager.shared.presentPicker(from: self) { [weak self] image, fileName in
            guard let self else {
                return
            }
            guard let originalImage = image else {
                return
            }
            if feature == .photoFilters {
                self.moveToImageEditorVC(feature: feature, image: originalImage)
            } else if feature == .backgroundRemover {
                self.moveToBGRemoverVC(feature: feature, image: originalImage)
            } else if feature == .imageResize {
                self.moveToImageResizeVC(feature: feature, image: originalImage, fileName: fileName)
            } else if feature == .imageUpscale {
                self.moveToImageUpscaleVC(feature: feature, image: originalImage)
            }
        }
    }

    private func moveToCameraVC(feature: Feature) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
        vc.title = feature.title
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func moveToImageEditorVC(feature: Feature, image: UIImage) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ImageEditorViewController") as! ImageEditorViewController
        vc.title = feature.title
        vc.originalImage = image
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func moveToBGRemoverVC(feature: Feature, image: UIImage) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "BackgroundRemoverViewController") as! BackgroundRemoverViewController
        vc.title = feature.title
        vc.originalImage = image
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func moveToImageResizeVC(feature: Feature, image: UIImage, fileName: String?) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ImageUpscaleViewController") as! ImageUpscaleViewController
        vc.title = feature.title
        vc.originalImage = image
        vc.fileName = fileName
        self.navigationController?.pushViewController(vc, animated: true)

    }

    private func moveToImageUpscaleVC(feature: Feature, image: UIImage) {

        let targetSize = CGSize(width: 512, height: 512)
        guard let croppedImage = image.croppedSquareImage(targetSize: targetSize) else {
            return
        }
        let vc = storyboard?.instantiateViewController(withIdentifier: "RealESRGANUpscaleViewController") as! RealESRGANUpscaleViewController
        vc.title = feature.title
        vc.originalImage = croppedImage
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
