//
//  TonalFilter.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation

struct TonalFilter: ImageFilterable {

    let id = "tonal"
    let title = "Tonal"
    let icon = "circle.dotted"
    let filterName = "CIPhotoEffectTonal"
    let supportsIntensity = false
    let defaultIntensity: Float = 1
    let intensityRange: ClosedRange<Float> = 0...1
}
