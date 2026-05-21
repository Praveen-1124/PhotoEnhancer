//
//  InvertFilter.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation

struct InvertFilter: ImageFilterable {

    let id = "invert"
    let title = "Invert"
    let icon = "arrow.triangle.2.circlepath"
    let filterName = "CIColorInvert"
    let supportsIntensity = false
    let defaultIntensity: Float = 1
    let intensityRange: ClosedRange<Float> = 0...1
}
