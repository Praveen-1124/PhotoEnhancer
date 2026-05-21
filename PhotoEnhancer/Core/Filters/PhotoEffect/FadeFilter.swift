//
//  FadeFilter.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation

struct FadeFilter: ImageFilterable {

    let id = "fade"
    let title = "Fade"
    let icon = "circle.lefthalf.filled"
    let filterName = "CIPhotoEffectFade"
    let supportsIntensity = false
    let defaultIntensity:Float = 1
    let intensityRange:ClosedRange<Float> = 0...1
}
