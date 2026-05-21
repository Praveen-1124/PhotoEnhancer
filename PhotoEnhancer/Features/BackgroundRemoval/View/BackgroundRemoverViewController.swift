//
//  BackgroundRemovalViewController.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 14/05/26.
//

import UIKit

class BackgroundRemoverViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!

    private var editedImage = UIImage()
    var originalImage = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        removeBackgroundTapped(image: self.originalImage)
    }

    deinit {

    }

    private func setupUI() {
        self.title = "Background Remover"
        self.imageView.image = originalImage
    }

    private func removeBackgroundTapped(image: UIImage) {

        self.activityIndicator.startAnimating()
        BackgroundRemover.shared.removeBackground(from: image) { [weak self] result in
            guard let self else { return }
            self.activityIndicator.stopAnimating()
            switch result {
            case .success(let output):
                self.editedImage = output
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    @IBAction func didClickSegmentControl(_ sender: UISegmentedControl) {

        let isEditedImage = sender.selectedSegmentIndex == 1
        imageView.image = isEditedImage ? editedImage : originalImage
    }
}
