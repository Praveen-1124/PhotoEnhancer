//
//  SharpnessAdjustment.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import CoreImage

struct SharpnessAdjustment: ImageAdjustable {

    let id = "sharpness"
    let title = "Sharpness"
    let icon = "sparkles"
    let filterName = "CISharpenLuminance"

    let defaultValue: Float = 0
    let sliderRange: ClosedRange<Float> = 0...2
    let stepValue: Float = 0.05
}

extension SharpnessAdjustment {

    func parameters(value: Float) -> [String : Any] {
        [kCIInputSharpnessKey: value]
    }
}
