//
//  OriginalFilter.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation

struct OriginalFilter: ImageFilterable {

    let id = "original"
    let title = "Original"
    let icon = "photo"
    let filterName = ""
    let supportsIntensity = false
    let defaultIntensity: Float = 0
    let intensityRange: ClosedRange<Float> = 0...1
}
