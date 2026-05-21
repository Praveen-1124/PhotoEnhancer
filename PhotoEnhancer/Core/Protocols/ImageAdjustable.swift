//
//  ImageAdjustable.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation
import CoreImage

protocol ImageAdjustable {

    var id: String { get }

    var title: String { get }

    var icon: String { get }

    var filterName: String { get }

    var defaultValue: Float { get }

    var sliderRange: ClosedRange<Float> { get }

    var stepValue: Float { get }

    func parameters(value: Float) -> [String: Any]
}

extension ImageAdjustable {

    func apply(to image: CIImage, value: Float) -> CIImage? {

        guard let filter = CIFilter(name: filterName) else {
            return image
        }

        filter.setValue(image, forKey: kCIInputImageKey)
        parameters(value: value).forEach {key, value in
            filter.setValue(value, forKey: key)
        }
        return filter.outputImage
    }
}


