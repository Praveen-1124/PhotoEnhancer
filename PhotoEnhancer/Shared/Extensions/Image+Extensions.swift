//
//  CIImage+Extensions.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import CoreImage
import ImageIO
import UIKit

extension CIImage {

    func downsampled(maxDimension: CGFloat) -> CIImage {
        let extent = extent
        let scale = min(maxDimension / extent.width, maxDimension / extent.height)
        return transformed(by: CGAffineTransform(scaleX: scale, y: scale))
    }
}


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
}
