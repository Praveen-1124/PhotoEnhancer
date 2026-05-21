//
//  BloomFilter.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation
import CoreImage

struct BloomFilter: ImageFilterable {

    let id = "bloom"
    let title = "Bloom"
    let icon = "sun.max.fill"
    let filterName = "CIBloom"
    let supportsIntensity = true
    let defaultIntensity: Float = 0.5
    let intensityRange: ClosedRange<Float> = 0...1
}

extension BloomFilter {

    func parameters(intensity: Float) -> [String : Any] {
        [kCIInputIntensityKey: intensity]
    }
}
