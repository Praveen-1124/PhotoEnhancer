//
//  ImageUpscaleConfiguration.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 25/05/26.
//

import Foundation
import UIKit

enum ImageExportFormat {
    case png
    case jpeg
    case heif
    case webp
}

struct BatchUpscaleResult {
    let index: Int
    let image: UIImage?
    let error: Error?
}

struct ImageUpscaleConfiguration {

    var targetWidth: CGFloat
    var targetHeight: CGFloat

    var maintainAspectRatio: Bool = true
    var shouldCrop: Bool = false

    /// Lanczos scaling
    var useLanczos: Bool = true

    /// PNG / HEIF / WEBP
    var exportFormat: ImageExportFormat = .png

    /// Compression quality (0...1)
    var compressionQuality: CGFloat = 1.0

    init(
        targetWidth: CGFloat,
        targetHeight: CGFloat,
        maintainAspectRatio: Bool = true,
        shouldCrop: Bool = false,
        useLanczos: Bool = true,
        exportFormat: ImageExportFormat = .png,
        compressionQuality: CGFloat = 1.0
    ) {
        self.targetWidth = targetWidth
        self.targetHeight = targetHeight
        self.maintainAspectRatio = maintainAspectRatio
        self.shouldCrop = shouldCrop
        self.useLanczos = useLanczos
        self.exportFormat = exportFormat
        self.compressionQuality = compressionQuality
    }
}
