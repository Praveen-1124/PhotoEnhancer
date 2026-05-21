//
//  AdjustmentRegistry.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation

enum AdjustmentRegistry {

    static let all: [ImageAdjustable] = [
        ExposureAdjustment(),
        BrightnessAdjustment(),
        ContrastAdjustment(),
        SaturationAdjustment(),
        VibranceAdjustment(),
        HueAdjustment(),
        TemperatureAdjustment(),
        SharpnessAdjustment(),
        BlurAdjustment(),
        VignetteAdjustment()
    ]
}
