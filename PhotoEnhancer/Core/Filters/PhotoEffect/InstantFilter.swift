//
//  InstantFilter.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation

struct InstantFilter: ImageFilterable {

    let id = "instant"
    let title = "Instant"
    let icon = "camera.aperture"
    let filterName = "CIPhotoEffectInstant"
    let supportsIntensity = false
    let defaultIntensity: Float = 1
    let intensityRange: ClosedRange<Float> = 0...1
}
