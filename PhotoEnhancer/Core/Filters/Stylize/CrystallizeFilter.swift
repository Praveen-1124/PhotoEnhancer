//
//  CrystallizeFilter.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import CoreImage

struct CrystallizeFilter: ImageFilterable {

    let id = "crystallize"
    let title = "Crystal"
    let icon = "square.grid.3x3.fill"
    let filterName = "CICrystallize"
    let supportsIntensity = true
    let defaultIntensity:Float = 15
    let intensityRange:ClosedRange<Float> = 1...50
}

extension CrystallizeFilter {

    func parameters(intensity: Float) -> [String : Any] {
        [kCIInputRadiusKey: intensity]
    }
}
