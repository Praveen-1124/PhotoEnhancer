//
//  VignetteAdjustment.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import CoreImage

struct VignetteAdjustment: ImageAdjustable {

    let id = "vignette"
    let title = "Vignette"
    let icon = "circle.dashed.inset.filled"
    let filterName = "CIVignette"

    let defaultValue: Float = 0
    let sliderRange: ClosedRange<Float> = 0...2
    let stepValue: Float = 0.05
}

extension VignetteAdjustment {

    func parameters(value: Float) -> [String : Any] {

        [kCIInputIntensityKey:value,
            kCIInputRadiusKey: value * 2]
    }
}
