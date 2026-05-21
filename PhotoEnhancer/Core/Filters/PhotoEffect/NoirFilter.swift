//
//  NoirFilter.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation

struct NoirFilter: ImageFilterable {

    let id = "noir"
    let title = "Noir"
    let icon = "moon.fill"
    let filterName = "CIPhotoEffectNoir"
    let supportsIntensity = false
    let defaultIntensity: Float = 1
    let intensityRange: ClosedRange<Float> = 0...1
}
