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
            moveToCameraVC()
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
            DispatchQueue.main.async {
                if feature == .photoFilters {
                    self.moveToImageEditorVC(image: originalImage)
                } else if feature == .backgroundRemover {
                    self.moveToBGRemoverVC(image: originalImage)
                } else if feature == .photoUpscaler {
                    self.moveToImageUpscaleVC(image: originalImage, fileName: fileName)
                }
            }
        }
    }

    private func moveToCameraVC() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func moveToImageEditorVC(image: UIImage) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ImageEditorViewController") as! ImageEditorViewController
        vc.originalImage = image
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func moveToBGRemoverVC(image: UIImage) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "BackgroundRemoverViewController") as! BackgroundRemoverViewController
        vc.originalImage = image
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func moveToImageUpscaleVC(image: UIImage, fileName: String?) {

        let vc = storyboard?.instantiateViewController(withIdentifier: "ImageUpscaleViewController") as! ImageUpscaleViewController
        vc.originalImage = image
        vc.fileName = fileName
        self.navigationController?.pushViewController(vc, animated: true)

    }
}
