//
//  ComicFilter.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation

struct ComicFilter: ImageFilterable {

    let id = "comic"
    let title = "Comic"
    let icon = "text.bubble.fill"
    let filterName = "CIComicEffect"
    let supportsIntensity = false
    let defaultIntensity: Float = 1
    let intensityRange: ClosedRange<Float> = 0...1
}
