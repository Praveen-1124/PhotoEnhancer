//
//  ImageUpscaleManager.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 25/05/26.
//

import UIKit
import CoreImage
import ImageIO
import UniformTypeIdentifiers

final class ImageUpscaleManager {

    static let shared = ImageUpscaleManager()

    private let ciContext = CIContext(options: [
        .useSoftwareRenderer: false
    ])

    private let processingQueue = DispatchQueue(
        label: "image.upscale.queue",
        qos: .userInitiated,
        attributes: .concurrent
    )

    private init() {}

    // MARK: Single Upscale

    func upscale(image: UIImage, configuration: ImageUpscaleConfiguration, completion: @escaping (UIImage?) -> Void) {

        processingQueue.async {
            let result = self.processImage(image: image, configuration: configuration)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    // MARK: Batch Upscale

    func upscaleBatch(images: [UIImage], configuration: ImageUpscaleConfiguration, completion: @escaping ([BatchUpscaleResult]) -> Void) {

        processingQueue.async {

            let group = DispatchGroup()
            var results: [BatchUpscaleResult] = []

            let lock = NSLock()

            for (index, image) in images.enumerated() {

                group.enter()

                self.processingQueue.async {

                    let processed = self.processImage(
                        image: image,
                        configuration: configuration)
                    let result = BatchUpscaleResult(index: index,
                                                    image: processed,
                                                    error: processed == nil ? NSError(domain: "UpscaleError", code: -1): nil)
                    lock.lock()
                    results.append(result)
                    lock.unlock()
                    group.leave()
                }
            }

            group.wait()
            let sorted = results.sorted {
                $0.index < $1.index
            }
            DispatchQueue.main.async {
                completion(sorted)
            }
        }
    }
}

// MARK: Core Processing
private extension ImageUpscaleManager {

    func processImage(image: UIImage, configuration: ImageUpscaleConfiguration) -> UIImage? {

        guard let cgImage = image.cgImage else {
            return nil
        }

        let originalSize = image.size

        let targetSize = CGSize(
            width: configuration.targetWidth,
            height: configuration.targetHeight
        )

        let finalSize: CGSize

        if configuration.maintainAspectRatio {
            finalSize = calculateAspectSize(
                originalSize: originalSize,
                targetSize: targetSize,
                crop: configuration.shouldCrop
            )
        } else {
            finalSize = targetSize
        }

        let scale = finalSize.width / originalSize.width
        let ciImage = CIImage(cgImage: cgImage)
        let scaledImage: CIImage

        if configuration.useLanczos {
            scaledImage = lanczosScale(image: ciImage, scale: scale)
        } else {
            scaledImage = ciImage.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        }

        guard let outputCGImage = ciContext.createCGImage(scaledImage, from: scaledImage.extent) else {
            return nil
        }

//        let scaledUIImage = UIImage(cgImage: outputCGImage)
        let scaledUIImage = UIImage(cgImage: outputCGImage, scale: 1.0, orientation: .up)
        return cropOrFit(image: scaledUIImage, canvasSize: targetSize, shouldCrop: configuration.shouldCrop)
    }
}

// MARK:  Lanczos Scaling

private extension ImageUpscaleManager {

    func lanczosScale(image: CIImage, scale: CGFloat) -> CIImage {

        guard let filter = CIFilter(name: "CILanczosScaleTransform") else {
            return image
        }

        filter.setValue(image, forKey: kCIInputImageKey)
        filter.setValue(scale, forKey: kCIInputScaleKey)
        filter.setValue(1.0, forKey: kCIInputAspectRatioKey)
        return filter.outputImage ?? image
    }
}

// MARK:  Crop / Fit

private extension ImageUpscaleManager {

    func cropOrFit(image: UIImage, canvasSize: CGSize, shouldCrop: Bool) -> UIImage {

        let renderer = renderer(size: canvasSize)

        return renderer.image { _ in

            let imageSize = image.size
            let rect: CGRect

            if shouldCrop {

                let x = (canvasSize.width - imageSize.width) / 2
                let y = (canvasSize.height - imageSize.height) / 2

                rect = CGRect(
                    x: x,
                    y: y,
                    width: imageSize.width,
                    height: imageSize.height
                )

            } else {

                let x = (canvasSize.width - imageSize.width) / 2
                let y = (canvasSize.height - imageSize.height) / 2

                rect = CGRect(
                    x: x,
                    y: y,
                    width: imageSize.width,
                    height: imageSize.height
                )
            }

            image.draw(in: rect)
        }
    }

    func calculateAspectSize(originalSize: CGSize, targetSize: CGSize, crop: Bool) -> CGSize {

        let widthRatio = targetSize.width / originalSize.width
        let heightRatio = targetSize.height / originalSize.height
        let scale = crop ? max(widthRatio, heightRatio) : min(widthRatio, heightRatio)

        return CGSize(width: originalSize.width * scale, height: originalSize.height * scale)
    }

    private func renderer(size: CGSize) -> UIGraphicsImageRenderer {

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        format.opaque = false
        return UIGraphicsImageRenderer(size: size, format: format)
    }
}

// MARK:  Export

extension ImageUpscaleManager {

    func exportImage(_ image: UIImage, configuration: ImageUpscaleConfiguration, to url: URL) throws {

        guard let cgImage = image.cgImage else {
            throw NSError(domain: "ExportError", code: -1)
        }

        let destinationUTType: CFString
        switch configuration.exportFormat {
        case .png:
            destinationUTType = UTType.png.identifier as CFString
        case .jpeg:
            destinationUTType = UTType.jpeg.identifier as CFString
        case .heif:
            destinationUTType = UTType.heic.identifier as CFString
        case .webp:

            if #available(iOS 14.0, *) {
                destinationUTType = "org.webmproject.webp" as CFString
            } else {
                throw NSError(domain: "WEBPUnsupported", code: -1)
            }
        }

        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, destinationUTType, 1, nil) else {
            throw NSError(domain: "ExportDestinationError", code: -1)
        }

        let options: [CFString: Any] = [kCGImageDestinationLossyCompressionQuality: configuration.compressionQuality]
        CGImageDestinationAddImage(destination, cgImage, options as CFDictionary)

        guard CGImageDestinationFinalize(destination) else {
            throw NSError(domain: "FinalizeExportError", code: -1)
        }
    }
}
