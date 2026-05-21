//
//  VignetteFilter.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation
import CoreImage

struct VignetteFilter: ImageFilterable {

    let id = "vignette"
    let title = "Vignette"
    let icon = "circle.dashed.inset.filled"
    let filterName = "CIVignette"
    let supportsIntensity = true
    let defaultIntensity: Float = 0.6
    let intensityRange: ClosedRange<Float> = 0...1
}

extension VignetteFilter {
    
    func parameters(intensity: Float) -> [String : Any] {
        [kCIInputIntensityKey:intensity,
            kCIInputRadiusKey:intensity * 2
        ]
    }
}
