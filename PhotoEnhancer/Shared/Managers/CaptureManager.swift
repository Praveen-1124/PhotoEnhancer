//
//  CaptureManager.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 13/05/26.
//

import UIKit
import AVFoundation

protocol CaptureManagerDelegate: AnyObject {
    func captureManager(_ manager: CaptureManager, didOutput image: CIImage)
}

final class CaptureManager: NSObject {

    weak var delegate: CaptureManagerDelegate?
    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "camera.session.queue", qos: .userInitiated)

    private let videoOutput = AVCaptureVideoDataOutput()
    private let photoOutput = AVCapturePhotoOutput()
    private let movieOutput = AVCaptureMovieFileOutput()

    private var videoDeviceInput: AVCaptureDeviceInput?
    private let ciContext = CIContext()
    private var currentPosition: AVCaptureDevice.Position = .back

    var filters: [CIFilter] = []

    override init() {
        super.init()
    }

    func configure() {

        sessionQueue.async {

            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
                return
            }

            do {

                let input = try AVCaptureDeviceInput(device: camera)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                    self.videoDeviceInput = input
                }
            } catch {
                print(error)
            }


            if let mic = AVCaptureDevice.default(for: .audio) {
                do {

                    let micInput = try AVCaptureDeviceInput(device: mic)

                    if self.session.canAddInput(micInput) {
                        self.session.addInput(micInput)
                    }

                } catch {
                    print(error)
                }
            }

            // Video Output
            self.videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            self.videoOutput.setSampleBufferDelegate(self, queue: self.sessionQueue)
            self.videoOutput.alwaysDiscardsLateVideoFrames = true

            if self.session.canAddOutput(self.videoOutput) {
                self.session.addOutput(self.videoOutput)
            }

            // Photo Output
            if self.session.canAddOutput(self.photoOutput) {
                self.session.addOutput(self.photoOutput)

                self.photoOutput.maxPhotoQualityPrioritization = .quality
            }

            // Movie Output
            if self.session.canAddOutput(self.movieOutput) {
                self.session.addOutput(self.movieOutput)
            }

            self.session.commitConfiguration()
            self.session.startRunning()
        }
    }

    func stopSession() {
        sessionQueue.async {
            self.session.stopRunning()
        }
    }


    func updateExposure(value: Float) {

        guard let device = videoDeviceInput?.device else {
            return
        }

        do {
            try device.lockForConfiguration()
            let exposure = min(max(value, device.minExposureTargetBias), device.maxExposureTargetBias)
            device.setExposureTargetBias(exposure) { _ in

            }
            device.unlockForConfiguration()

        } catch {
            print(error)
        }
    }

    func focus(at point: CGPoint) {

        guard let device = videoDeviceInput?.device else {
            return
        }

        do {

            try device.lockForConfiguration()
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
            }

            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
                device.exposureMode = .continuousAutoExposure
            }
            device.unlockForConfiguration()

        } catch {
            print(error)
        }
    }

    func switchCamera() {

        sessionQueue.async {

            guard let currentInput = self.videoDeviceInput else {
                return
            }

            self.session.beginConfiguration()
            self.session.removeInput(currentInput)
            self.currentPosition = self.currentPosition == .back ? .front : .back

            guard let newDevice = AVCaptureDevice.default( .builtInWideAngleCamera, for: .video, position: self.currentPosition) else {
                return
            }

            do {
                let newInput = try AVCaptureDeviceInput(device: newDevice)
                if self.session.canAddInput(newInput) {
                    self.session.addInput(newInput)
                    self.videoDeviceInput = newInput
                }

            } catch {
                print(error)
            }

            self.session.commitConfiguration()
        }
    }
}

// MARK:  Filters
extension CaptureManager {

    private func applyFilters(to image: CIImage) -> CIImage {

        var output = image
        for filter in filters {
            filter.setValue(output, forKey: kCIInputImageKey)
            if let filtered = filter.outputImage {
                output = filtered
            }
        }

        return output
    }
}

// MARK:  Video Frames
extension CaptureManager: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let image = CIImage(cvPixelBuffer: pixelBuffer)
        let filtered = applyFilters(to: image)
        self.delegate?.captureManager(self, didOutput: filtered)
    }
}

// MARK: Photo
extension CaptureManager: AVCapturePhotoCaptureDelegate {

    private struct Holder {
        static var completion: ((UIImage?) -> Void)?
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {

        Holder.completion = completion

        let settings: AVCapturePhotoSettings
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            settings = AVCapturePhotoSettings(
                format: [
                    AVVideoCodecKey: AVVideoCodecType.hevc
                ]
            )
        } else {
            settings = AVCapturePhotoSettings()
        }

        settings.photoQualityPrioritization = .quality
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        guard error == nil else {
            Holder.completion?(nil)
            return
        }

        guard let data = photo.fileDataRepresentation(),
              let ciImage = CIImage(data: data) else {
            Holder.completion?(nil)
            return
        }

        let filtered = applyFilters(to: ciImage)
        guard let cgImage = ciContext.createCGImage(filtered, from: filtered.extent) else {
            Holder.completion?(nil)
            return
        }

        let image = UIImage(cgImage: cgImage)
        Holder.completion?(image)
    }
}

// MARK: Video Recording
extension CaptureManager: AVCaptureFileOutputRecordingDelegate {

    func startRecording() {

        guard !movieOutput.isRecording else {
            return
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mov")
        movieOutput.startRecording(to: url, recordingDelegate: self)
    }

    func stopRecording() {

        guard movieOutput.isRecording else {
            return
        }

        movieOutput.stopRecording()
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {

        if let error {
            print(error)
            return
        }

        UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, nil, nil, nil)
    }
}
