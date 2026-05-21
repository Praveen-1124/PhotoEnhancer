//
//  SaturationAdjustment.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import CoreImage

struct SaturationAdjustment: ImageAdjustable {

    let id = "saturation"
    let title = "Saturation"
    let icon = "paintpalette"
    let filterName = "CIColorControls"

    let defaultValue: Float = 1
    let sliderRange: ClosedRange<Float> = 0...2
    let stepValue: Float = 0.05
}

extension SaturationAdjustment {

    func parameters(value: Float) -> [String : Any] {
        [kCIInputSaturationKey: value]
    }
}
