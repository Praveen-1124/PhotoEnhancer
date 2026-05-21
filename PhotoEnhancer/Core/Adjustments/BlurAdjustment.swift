//
//  BlurAdjustment.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import CoreImage

struct BlurAdjustment: ImageAdjustable {
    let id = "blur"
    let title = "Blur"
    let icon = "drop"
    let filterName = "CIGaussianBlur"

    let defaultValue: Float = 0
    let sliderRange: ClosedRange<Float> = 0...30
    let stepValue: Float = 1
}

extension BlurAdjustment {

    func parameters(value: Float) -> [String : Any] {
        [kCIInputRadiusKey: value]
    }
}
