//
//  ContrastAdjustment.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import CoreImage

struct ContrastAdjustment:ImageAdjustable {

    let id = "contrast"
    let title = "Contrast"
    let icon = "circle.lefthalf.filled"
    let filterName = "CIColorControls"
    
    let defaultValue:Float = 1
    let sliderRange: ClosedRange<Float> = 0...4
    let stepValue: Float = 0.05    
}

extension ContrastAdjustment {

  func parameters(value: Float) -> [String : Any] {
        [kCIInputContrastKey: value]
    }
}
