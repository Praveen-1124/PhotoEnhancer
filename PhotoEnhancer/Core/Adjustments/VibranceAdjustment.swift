//
//  VibranceAdjustment.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import CoreImage

struct VibranceAdjustment: ImageAdjustable {

    let id = "vibrance"
    let title = "Vibrance"
    let icon = "sparkles"
    let filterName = "CIVibrance"

    let defaultValue: Float = 0
    let sliderRange: ClosedRange<Float> = -1...1
    let stepValue: Float = 0.05
}

extension VibranceAdjustment {

    func parameters(value: Float) -> [String : Any] {
        
        ["inputAmount": value]
    }
}
