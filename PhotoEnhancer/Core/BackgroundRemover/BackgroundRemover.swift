//
//  BackgroundRemover.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 14/05/26.
//

import UIKit
import Vision
import CoreImage
import Metal

final class BackgroundRemover {

    static let shared = BackgroundRemover()
    private let ciContext: CIContext
    private let processingQueue = DispatchQueue(label: "com.app.backgroundremoval", qos: .userInitiated)

    private init() {

        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device")
        }

        self.ciContext = CIContext(mtlDevice: device, options: [
            .cacheIntermediates: false,
            .priorityRequestLow: true
        ])
    }


    func removeBackground(from image: UIImage, completion: @escaping (Result<UIImage, Error>) -> Void) {

        processingQueue.async {
            autoreleasepool {
                do {
                    let result = try self.process(image)
                    DispatchQueue.main.async {
                        completion(.success(result))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}

private extension BackgroundRemover {

    func process(_ image: UIImage) throws -> UIImage {

        guard let cgImage = image.cgImage else {
            throw BackgroundRemoverError.invalidImage
        }

        // Downsample large images to avoid memory spikes
        let optimizedCGImage = try downsampleIfNeeded(cgImage)
        let request = VNGenerateForegroundInstanceMaskRequest()

        let handler = VNImageRequestHandler(
            cgImage: optimizedCGImage,
            orientation: image.cgImageOrientation
        )

        try handler.perform([request])

        guard let observation = request.results?.first else {
            throw BackgroundRemoverError.maskGenerationFailed
        }

        let maskPixelBuffer = try observation.generateScaledMaskForImage(
            forInstances: observation.allInstances,
            from: handler
        )

        return try renderFinalImage(original: optimizedCGImage, mask: maskPixelBuffer)
    }
}


private extension BackgroundRemover {

    func renderFinalImage(original: CGImage, mask: CVPixelBuffer) throws -> UIImage {

        let originalCI = CIImage(cgImage: original)
        let maskCI = CIImage(cvPixelBuffer: mask)
        let transparentBackground = CIImage.empty()

        guard let blendFilter = CIFilter(name: "CIBlendWithMask") else {
            throw BackgroundRemoverError.renderFailed
        }

        blendFilter.setValue(originalCI, forKey: kCIInputImageKey)
        blendFilter.setValue(maskCI, forKey: kCIInputMaskImageKey)
        blendFilter.setValue(transparentBackground, forKey: kCIInputBackgroundImageKey)

        guard let output = blendFilter.outputImage else {
            throw BackgroundRemoverError.renderFailed
        }

        guard let cgImage = ciContext.createCGImage(output, from: output.extent) else {
            throw BackgroundRemoverError.renderFailed
        }

        return UIImage(cgImage: cgImage)
    }
}


private extension BackgroundRemover {

    func downsampleIfNeeded(_ cgImage: CGImage, maxDimension: CGFloat = 2048) throws -> CGImage {

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let largestDimension = max(width, height)

        guard largestDimension > maxDimension else {
            return cgImage
        }

        let scale = maxDimension / largestDimension
        let resizedWidth = Int(width * scale)
        let resizedHeight = Int(height * scale)
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(
                data: nil,
                width: resizedWidth,
                height: resizedHeight,
                bitsPerComponent: 8,
                bytesPerRow: 0,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            throw BackgroundRemoverError.downsamplingFailed
        }

        context.interpolationQuality = .medium
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: resizedWidth, height: resizedHeight))

        guard let resizedImage = context.makeImage() else {
            throw BackgroundRemoverError.downsamplingFailed
        }

        return resizedImage
    }
}
