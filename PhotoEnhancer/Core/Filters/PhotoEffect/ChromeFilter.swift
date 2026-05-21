//
//  ChromeFilter.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation

struct ChromeFilter: ImageFilterable {

    let id = "chrome"
    let title = "Chrome"
    let icon = "camera.filters"
    let filterName = "CIPhotoEffectChrome"
    let supportsIntensity = false
    let defaultIntensity: Float = 1
    let intensityRange: ClosedRange<Float> = 0...1
}
