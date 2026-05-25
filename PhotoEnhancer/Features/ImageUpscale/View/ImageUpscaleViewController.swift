//
//  ImageUpscaleViewController.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 22/05/26.
//

import UIKit

class ImageUpscaleViewController: UIViewController {

    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var originalImageSizeLabel: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var originalImageView: UIImageView!
    @IBOutlet weak var aspectRatioSwitch: UISwitch!
    @IBOutlet weak var cropSwitch: UISwitch!
    @IBOutlet weak var qualitySlider: UISlider!
    @IBOutlet weak var compressionQualityLabel: UILabel!
    
    @IBOutlet weak var widthTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!

    var originalImage = UIImage()
    var fileName: String?
    private var compressionQuality: CGFloat = 1.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    deinit {
        print("\(Self.self): Deinited")
    }

    private func setupUI() {

        self.title = "Photo Upscale"

        let size = originalImage.size
        let width = "\(Int(size.width))"
        let height = "\(Int(size.height))"

        widthTextField.text = width
        heightTextField.text = height
        fileNameLabel.text = fileName.orEmpty

        originalImageView.image = originalImage
        originalImageSizeLabel.text = width + "X" + height
    }


    @IBAction func didChangeQuality(_ sender: UISlider) {
        compressionQuality = CGFloat(sender.value * 100)
        compressionQualityLabel.text = "\(Int(compressionQuality))%"
    }

    @IBAction func didClickResizeButton(_ sender: FeatureButton) {

        let width = widthTextField.text.orEmpty.toDouble
        let height = heightTextField.text.orEmpty.toDouble

        guard width > 0 && height > 0 else {
            showAlert(type: .info, message: "Please enter a valid size")
            return
        }

        let maintainAspectRatio = aspectRatioSwitch.isOn
        let shouldCrop = cropSwitch.isOn
        let config = ImageUpscaleConfiguration(targetWidth: width,
                                               targetHeight: height,
                                               maintainAspectRatio: !maintainAspectRatio,
                                               shouldCrop: shouldCrop,
                                               compressionQuality: compressionQuality)

        ImageUpscaleManager.shared.upscale(image: originalImage, configuration: config) { [weak self] image in
            guard let self else { return }
            DispatchQueue.main.async {
                self.previewImageView.image = image
                self.heightTextField.resignFirstResponder()
                self.widthTextField.resignFirstResponder()
            }
        }
    }

    @IBAction func didClickExportButton(_ sender: FeatureButton) {

        guard let upscaledImage = previewImageView.image else {
            return
        }

        let config = PhotoAlbumConfiguration(albumName: "Photo Enhancer")
        PhotoSaveManager.shared.saveImage(upscaledImage,
                                          configuration: config) {[weak self] result in
            guard let self else { return }
            switch result {
            case .success(_):
                self.showAlert(type: .success, message: "Photo Saved Successfully")
            case .failure(let failure):
                self.showAlert(type: .error, message: failure.localizedDescription)
            }
        }
    }
}
