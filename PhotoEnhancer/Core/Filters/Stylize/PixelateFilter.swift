//
//  PixelateFilter.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import CoreImage

struct PixelateFilter: ImageFilterable {

    let id = "pixelate"
    let title = "Pixel"
    let icon = "square.fill.on.square.fill"
    let filterName = "CIPixellate"
    let supportsIntensity = true
    let defaultIntensity: Float = 8
    let intensityRange: ClosedRange<Float> = 1...30
}

extension PixelateFilter {

    func parameters(intensity: Float) -> [String : Any] {
        [kCIInputScaleKey: intensity]
    }
}
