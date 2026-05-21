//
//  ProcessFilter.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation

struct ProcessFilter: ImageFilterable {

    let id = "process"
    let title = "Process"
    let icon = "sparkles"
    let filterName = "CIPhotoEffectProcess"
    let supportsIntensity = false
    let defaultIntensity: Float = 1
    let intensityRange: ClosedRange<Float> = 0...1
}
