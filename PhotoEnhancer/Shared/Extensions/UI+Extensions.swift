//
//  UI+Extensions.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 25/05/26.
//

import Foundation
import CoreImage
import ImageIO
import UIKit

//MARK: - UIViewController

extension UIViewController {

    func showAlert(type: AlertType, message: String,
                   buttonTitle: String = "OK", completion: (() -> Void)? = nil) {

        let alert = UIAlertController(title: type.title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default) { _ in
            completion?()
        }
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}


//MARK: - UICollectionView

extension UICollectionView {

    func register(_ cells: [UICollectionViewCell.Type]) {
        cells.forEach {
            let identifier = String(describing: $0)
            self.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
        }
    }
}

extension UICollectionViewCell {

    static var rid: String {
        String(describing: Self.self)
    }
}


//MARK: - UIImage
extension UIImage {

    var cgImageOrientation: CGImagePropertyOrientation {

        switch imageOrientation {

        case .up:
            return .up

        case .down:
            return .down

        case .left:
            return .left

        case .right:
            return .right

        case .upMirrored:
            return .upMirrored

        case .downMirrored:
            return .downMirrored

        case .leftMirrored:
            return .leftMirrored

        case .rightMirrored:
            return .rightMirrored

        @unknown default:
            return .up
        }
    }

    func croppedSquareImage(targetSize: CGSize = CGSize(width: 512, height: 512)) -> UIImage? {

        guard let cgImage = self.cgImage else {
            return nil
        }

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)

        // MARK: Square Crop Size
        let cropSize = min(width, height)
        // MARK: Center Crop Origin
        let cropX = (width - cropSize) / 2
        let cropY = (height - cropSize) / 2
        let cropRect = CGRect(x: cropX, y: cropY, width: cropSize, height: cropSize)

        guard let croppedCGImage = cgImage.cropping(to: cropRect) else {
            return nil
        }

        let croppedImage = UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            croppedImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}

//MARK: - CIImage
extension CIImage {

    func downsampled(maxDimension: CGFloat) -> CIImage {
        let extent = extent
        let scale = min(maxDimension / extent.width, maxDimension / extent.height)
        return transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    }
}

//------------------------------------------EOF---------------------------------------------------------------------
