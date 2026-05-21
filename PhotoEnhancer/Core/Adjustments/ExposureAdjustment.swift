//
//  ExposureAdjustment.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import CoreImage

struct ExposureAdjustment: ImageAdjustable {

    let id = "exposure"
    let title = "Exposure"
    let icon = "plusminus.circle"
    let filterName = "CIExposureAdjust"

    let defaultValue: Float = 0
    let sliderRange: ClosedRange<Float> = -10...10
    let stepValue: Float = 0.5
}

extension ExposureAdjustment {

    func parameters(value: Float ) -> [String : Any] {
        [kCIInputEVKey: value ]
    }
}
