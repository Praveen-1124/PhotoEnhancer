//
//  HueAdjustment.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import CoreImage

struct HueAdjustment: ImageAdjustable {

    let id = "hue"
    let title = "Hue"
    let icon = "circle.hexagongrid"
    let filterName = "CIHueAdjust"
    let defaultValue: Float = 0
    let sliderRange: ClosedRange<Float> = -3.14...3.14
    let stepValue: Float = 0.1
}

extension HueAdjustment {

    func parameters(value: Float) -> [String : Any] {

        [kCIInputAngleKey: value]
    }
}
