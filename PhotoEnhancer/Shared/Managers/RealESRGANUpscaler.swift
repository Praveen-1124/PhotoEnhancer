//
//  Untitled.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 27/05/26.
//
import UIKit
import Vision
import CoreML
import CoreImage

final class RealESRGANUpscaler {

    // MARK: Singleton

    static let shared = RealESRGANUpscaler()

    // MARK: Properties
    private var vnModel: VNCoreMLModel?

    private let modelQueue = DispatchQueue(
        label: "com.realesrgan.model.queue",
        qos: .userInitiated
    )

    private let inferenceQueue = DispatchQueue(
        label: "com.realesrgan.inference.queue",
        qos: .userInitiated
    )

    private static let ciContext = CIContext(options: [
        .cacheIntermediates: true
    ])

    private var isLoadingModel = false
    private var pendingModelCompletions: [(Error?) -> Void] = []


    private init() {}

    var isModelLoaded: Bool {
        vnModel != nil
    }

    // MARK:  Load Model
    func loadModel(completion: ((Error?) -> Void)? = nil) {

        // Already loaded
        if vnModel != nil {
            completion?(nil)
            return
        }

        // Store callbacks
        if let completion {
            pendingModelCompletions.append(completion)
        }

        // Prevent duplicate loading
        guard !isLoadingModel else {
            return
        }

        isLoadingModel = true

        modelQueue.async { [weak self] in

            guard let self else { return }

            do {

                let config = MLModelConfiguration()
                config.computeUnits = .all // Best performance

                // Load CoreML model
//                let coreMLModel = try RealESRGAN512(configuration: config).model
                let coreMLModel = try BSRGAN(configuration: config).model


                // Convert to Vision model
                let visionModel = try VNCoreMLModel(for: coreMLModel)

                self.vnModel = visionModel
                self.isLoadingModel = false

                DispatchQueue.main.async {
                    self.pendingModelCompletions.forEach {$0(nil)}
                    self.pendingModelCompletions.removeAll()
                }

            } catch {

                self.isLoadingModel = false
                DispatchQueue.main.async {
                    self.pendingModelCompletions.forEach {$0(error)}
                    self.pendingModelCompletions.removeAll()
                }
            }
        }
    }

    // MARK: - Upscale
    func upscale(image: UIImage, completion: @escaping (Result<UIImage, Error>) -> Void) {

        // Ensure model loaded
        if vnModel == nil {
            loadModel { [weak self] error in
                if let error {
                    completion(.failure(error))
                    return
                }
                self?.performUpscale(image: image, completion: completion)
            }
            return
        }

        performUpscale(image: image, completion: completion)
    }
}

// MARK: - Private Upscale

private extension RealESRGANUpscaler {

    func performUpscale(image: UIImage, completion: @escaping (Result<UIImage, Error>) -> Void) {

        guard let vnModel else {
            completion(.failure(UpscaleError.modelNotLoaded))
            return
        }

        guard let cgImage = image.cgImage else {
            completion(.failure(UpscaleError.invalidImage))
            return
        }

        inferenceQueue.async {

            let request = VNCoreMLRequest(model: vnModel) { request, error in

                // MARK: - Error
                if let error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }

                guard let results = request.results,
                      !results.isEmpty else {
                    DispatchQueue.main.async {
                        completion(.failure(UpscaleError.noResults))
                    }
                    return
                }

                // MARK: VNPixelBufferObservation

                if let observation = results.first as? VNPixelBufferObservation {
                    let pixelBuffer = observation.pixelBuffer

                    guard let image = Self.image(from: pixelBuffer) else {
                        DispatchQueue.main.async {
                            completion(.failure(UpscaleError.outputConversionFailed))
                        }

                        return
                    }

                    DispatchQueue.main.async {
                        completion(.success(image))
                    }

                    return
                }

                // MARK:  VNCoreMLFeatureValueObservation
                if let observation = results.first as? VNCoreMLFeatureValueObservation {

                    // MARK: PixelBuffer
                    if let pixelBuffer = observation.featureValue.imageBufferValue {

                        guard let image = Self.image(from: pixelBuffer) else {
                            DispatchQueue.main.async {
                                completion(.failure(UpscaleError.outputConversionFailed))
                            }
                            return
                        }

                        DispatchQueue.main.async {
                            completion(.success(image))
                        }
                        return
                    }

                    // MARK: MLMultiArray

                    if let multiArray = observation.featureValue.multiArrayValue {

                        guard let image = Self.image(from: multiArray) else {
                            DispatchQueue.main.async {
                                completion(.failure(UpscaleError.outputConversionFailed))
                            }
                            return
                        }
                        DispatchQueue.main.async {
                            completion(.success(image))
                        }
                        return
                    }
                }

                DispatchQueue.main.async {
                    completion(.failure(UpscaleError.unsupportedOutput))
                }
            }

            request.imageCropAndScaleOption = .centerCrop

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: Image Conversion

private extension RealESRGANUpscaler {

    // MARK: PixelBuffer -> UIImage

    static func image(from pixelBuffer: CVPixelBuffer) -> UIImage? {

        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    // MARK: MLMultiArray -> UIImage

    static func image(from multiArray: MLMultiArray) -> UIImage? {

        let shape = multiArray.shape.map {
            Int(truncating: $0)
        }

        guard shape.count == 4 else {
            return nil
        }

        let channels = shape[1]
        let height = shape[2]
        let width = shape[3]

        guard channels >= 3 else {
            return nil
        }

        let pointer = UnsafeMutablePointer<Float32>(OpaquePointer(multiArray.dataPointer))
        var pixels = [UInt8](repeating: 0, count: width * height * 4)

        for y in 0..<height {

            for x in 0..<width {

                let rIndex = (0 * height * width) + (y * width) + x
                let gIndex = (1 * height * width) + (y * width) + x
                let bIndex = (2 * height * width) + (y * width) + x

                let r = pointer[rIndex]
                let g = pointer[gIndex]
                let b = pointer[bIndex]

                let pixelIndex = (y * width + x) * 4

                pixels[pixelIndex + 0] = UInt8(
                    max(0, min(255, r * 255))
                )

                pixels[pixelIndex + 1] = UInt8(
                    max(0, min(255, g * 255))
                )

                pixels[pixelIndex + 2] = UInt8(
                    max(0, min(255, b * 255))
                )

                pixels[pixelIndex + 3] = 255
            }
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        guard let cgImage = context.makeImage() else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Errors
enum UpscaleError: LocalizedError {

    case modelNotLoaded
    case invalidImage
    case noResults
    case unsupportedOutput
    case outputConversionFailed

    var errorDescription: String? {

        switch self {
        case .modelNotLoaded:
            return "Model not loaded"
        case .invalidImage:
            return "Invalid input image"
        case .noResults:
            return "No output received"
        case .unsupportedOutput:
            return "Unsupported model output"
        case .outputConversionFailed:
            return "Failed to convert output image"
        }
    }
}
