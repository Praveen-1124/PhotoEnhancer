//
//  MonoFilter.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation

struct MonoFilter: ImageFilterable {

    let id = "mono"
    let title = "Mono"
    let icon = "circle.fill"
    let filterName = "CIPhotoEffectMono"
    let supportsIntensity = false
    let defaultIntensity:Float = 1
    let intensityRange: ClosedRange<Float> = 0...1
}
