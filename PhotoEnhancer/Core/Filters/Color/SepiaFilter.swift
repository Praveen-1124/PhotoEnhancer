//
//  SepiaFilter.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation
import CoreImage

struct SepiaFilter: ImageFilterable {

    var id: String = "sepia"
    var title: String = "Sepia"
    var icon: String = "drop.fill"
    var filterName: String = "CISepiaTone"

    var defaultIntensity: Float = 0.8
    var intensityRange: ClosedRange<Float> = 0...1
    var supportsIntensity: Bool = true

    func parameters(intensity: Float) -> [String : Any] {
        return [kCIInputIntensityKey: intensity]
    }
}
