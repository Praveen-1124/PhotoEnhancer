//
//  BrightnessAdjustment.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import CoreImage

struct BrightnessAdjustment: ImageAdjustable {

    let id = "brightness"
    let title = "Brightness"
    let icon = "sun.max"
    let filterName = "CIColorControls"

    let defaultValue: Float = 0
    let sliderRange: ClosedRange<Float> = -1...1
    let stepValue: Float = 0.05   
}

extension BrightnessAdjustment {

    func parameters(value: Float) -> [String : Any] {
        [kCIInputBrightnessKey: value]
    }
}
