//
//  TemperatureAdjustment.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import CoreImage

struct TemperatureAdjustment: ImageAdjustable {

    let id = "temperature"
    let title = "Temperature"
    let icon = "thermometer.sun"
    let filterName = "CITemperatureAndTint"

    let defaultValue: Float = 6500
    let sliderRange: ClosedRange<Float> = 2000...12000
    let stepValue: Float = 100
}

extension TemperatureAdjustment {

    func parameters(value: Float) -> [String : Any] {

        ["inputNeutral": CIVector(x: CGFloat(value),y: 0),
         "inputTargetNeutral": CIVector(x: 6500, y: 0)]
    }
}
