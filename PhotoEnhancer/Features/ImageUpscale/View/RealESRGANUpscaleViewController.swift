//
//  RealESRGANUpscaleViewController.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 28/05/26.
//

import UIKit

class RealESRGANUpscaleViewController: UIViewController {

    @IBOutlet weak var statusStackView: UIStackView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    private var editedImage = UIImage()
    var originalImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    deinit {
        print("\(Self.self): Deinited")
    }

    private func setupUI() {

        imageView.image = originalImage
        upscaleImage(for: self.originalImage)
    }

    private func upscaleImage(for image: UIImage) {

        setLoaderVisiblity(isShow: true)
        RealESRGANUpscaler.shared.upscale(image: image) { [weak self] (result: Result<UIImage, Error>) in
            guard let self else { return }
            DispatchQueue.main.async {
                self.setLoaderVisiblity(isShow: false)
                switch result {
                case .success(let image):
                    self.editedImage = image
                    if self.segmentControl.selectedSegmentIndex == 1 {
                        self.imageView.image = image
                    }
                case .failure(let error):
                    self.showAlert(type: .error, message: error.localizedDescription)
                }
            }
        }
    }

    private func setLoaderVisiblity(isShow: Bool) {
        _ = isShow ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        statusStackView.isHidden = !isShow
    }

    @IBAction func didClickSegmentControl(_ sender: UISegmentedControl) {

        let isEditedImage = sender.selectedSegmentIndex == 1
        imageView.image = isEditedImage ? editedImage : originalImage
    }
}
