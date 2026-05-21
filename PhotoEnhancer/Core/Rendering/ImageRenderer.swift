//
//  ImageRenderer.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import UIKit
import Metal
import CoreImage
import CoreImage.CIFilterBuiltins

final class ImageRenderer {

    static let shared = ImageRenderer()
    private let device = MTLCreateSystemDefaultDevice()

    private lazy var context: CIContext = {

        if let device {
            return CIContext(mtlDevice: device, options: [
                .cacheIntermediates: false,
                .priorityRequestLow: true,
                .workingColorSpace: NSNull(),
                .outputColorSpace: NSNull(),
                .useSoftwareRenderer: false
            ])
        }

        return CIContext(options: [
            .cacheIntermediates: false,
            .priorityRequestLow: true
        ])
    }()


    private init() {

    }

    // MARK: Main Rendering
    func render(image: CIImage, state: EditorState, filters: [ImageFilterable], adjustments: [ImageAdjustable]) -> UIImage {

        autoreleasepool {

            var workingImage = image

            if let filterID = state.selectedFilterID,
               let filter = filters.first(where: {$0.id == filterID}) {
                let intensity = state.filterIntensityMap[filterID] ?? filter.defaultIntensity
                workingImage = filter.apply(to: workingImage, intensity: intensity ) ?? workingImage
            }

            adjustments.forEach { adjustment in
                let value = state.adjustmentIntensityMap[adjustment.id] ?? adjustment.defaultValue
                // Skip default value
                guard value != adjustment.defaultValue else {
                    return
                }
                workingImage = adjustment.apply(to: workingImage, value: value ) ?? workingImage
            }

            return makeUIImage(from: workingImage) // Render UIImage
        }
    }
}


// MARK: UIImage Rendering
private extension ImageRenderer {

    func makeUIImage(from image: CIImage) -> UIImage {

        let extent = image.extent.integral
        guard let cgImage = context.createCGImage(image, from: extent) else {
            return UIImage()
        }
        return UIImage(cgImage: cgImage)
    }
}


// MARK: Export Rendering
extension ImageRenderer {

    func exportImage(originalImage: CIImage, state: EditorState, filters: [ImageFilterable], adjustments: [ImageAdjustable]) -> UIImage {

        autoreleasepool {

            var workingImage = originalImage

            // MARK: Full Resolution Filter
            if let filterID = state.selectedFilterID,
               let filter = filters.first( where: {$0.id == filterID}) {

                let intensity = state.filterIntensityMap[filterID] ?? filter.defaultIntensity
                workingImage = filter.apply(to: workingImage, intensity: intensity) ?? workingImage
            }

            // MARK: Full Resolution Adjustments
            adjustments.forEach { adjustment in

                let value = state.adjustmentIntensityMap[ adjustment.id] ?? adjustment.defaultValue

                guard value != adjustment.defaultValue else {
                    return
                }
                workingImage = adjustment.apply(to: workingImage, value: value) ?? workingImage
            }

            return makeUIImage(from: workingImage)
        }
    }
}


// MARK: Thumbnail Rendering
extension ImageRenderer {

    func generateThumbnail(image: CIImage, filter: ImageFilterable,
                           size: CGSize = CGSize(width: 256, height: 256)) -> UIImage {
        autoreleasepool {
            let scale = min(size.width / image.extent.width, size.height / image.extent.height)
            let resizedImage = image.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
            let filteredImage = filter.apply( to: resizedImage, intensity: filter.defaultIntensity ) ?? resizedImage
            return makeUIImage(from: filteredImage)
        }
    }
}

// MARK: Image Resizer
extension ImageRenderer {

    func resizeAspectFit(image: UIImage, targetWidth: CGFloat, targetHeight: CGFloat) -> UIImage? {

        guard let ciImage = CIImage(image: image) else {
            return nil
        }

        let originalSize = ciImage.extent.size
        let widthRatio = targetWidth / originalSize.width
        let heightRatio = targetHeight / originalSize.height

        let scale = min(widthRatio, heightRatio)

        let lanczos = CIFilter.lanczosScaleTransform()
        lanczos.inputImage = ciImage
        lanczos.scale = Float(scale)
        lanczos.aspectRatio = 1.0

        let context = CIContext()

        guard let output = lanczos.outputImage,
              let cgImage = context.createCGImage(output, from: output.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}

// MARK:  Memory Cleanup
extension ImageRenderer {
    func clearCaches() {
        context.clearCaches()
    }
}
