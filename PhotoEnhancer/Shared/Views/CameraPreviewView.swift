//
//  CameraPreviewView.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 13/05/26.
//

import UIKit
import MetalKit
import CoreImage

final class CameraPreviewView: UIView {

    private let metalView: MTKView
    private let commandQueue: MTLCommandQueue
    private let ciContext: CIContext

    private let imageQueue = DispatchQueue(label: "camera.preview.image.queue")
    private var currentImage: CIImage?


    override init(frame: CGRect) {

        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            fatalError("Metal unsupported")
        }

        self.metalView = MTKView(frame: .zero, device: device)
        self.commandQueue = commandQueue
        self.ciContext = CIContext(mtlDevice: device)
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {

        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            return nil
        }

        self.metalView = MTKView(frame: .zero, device: device)
        self.commandQueue = commandQueue
        self.ciContext = CIContext(mtlDevice: device)
        super.init(coder: coder)
        setupUI()
    }


    private func setupUI() {

        backgroundColor = .black

        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.delegate = self
        metalView.framebufferOnly = false
        metalView.enableSetNeedsDisplay = false
        metalView.isPaused = false
        metalView.autoResizeDrawable = true
        metalView.preferredFramesPerSecond = 60
        metalView.colorPixelFormat = .bgra8Unorm

        addSubview(metalView)

        NSLayoutConstraint.activate([
            metalView.topAnchor.constraint(
                equalTo: topAnchor
            ),
            metalView.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            metalView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            metalView.bottomAnchor.constraint(
                equalTo: bottomAnchor
            )
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        metalView.frame = bounds
    }

    func render(image: CIImage) {

        imageQueue.async { [weak self] in
            self?.currentImage = image
        }
    }
}

// MARK: MTKViewDelegate
extension CameraPreviewView: MTKViewDelegate {

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {

    }

    func draw(in view: MTKView) {

        autoreleasepool {

            guard let drawable = view.currentDrawable,
                  let commandBuffer =
                    commandQueue.makeCommandBuffer()
            else {
                return
            }

            var image: CIImage?

            imageQueue.sync {
                image = currentImage
            }

            guard let image else {
                return
            }

            // Portrait Rotation

            let rotated = image.oriented(.right)

            // Aspect Fill

            let drawableSize = view.drawableSize
            let imageSize = rotated.extent.size
            let scale = max(
                drawableSize.width / imageSize.width,
                drawableSize.height / imageSize.height
            )

            let scaled = rotated.transformed(
                by: CGAffineTransform(
                    scaleX: scale,
                    y: scale
                )
            )

            let cropRect = CGRect(
                x: (scaled.extent.width - drawableSize.width) / 2,
                y: (scaled.extent.height - drawableSize.height) / 2,
                width: drawableSize.width,
                height: drawableSize.height
            )

            let cropped = scaled.cropped(
                to: cropRect
            )

            ciContext.render(
                cropped,
                to: drawable.texture,
                commandBuffer: commandBuffer,
                bounds: cropped.extent,
                colorSpace: CGColorSpaceCreateDeviceRGB()
            )

            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}
