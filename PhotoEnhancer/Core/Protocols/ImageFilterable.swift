//
//  ImageFilterable.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation
import CoreImage

protocol ImageFilterable {

    var id: String { get }

    var title: String { get }

    var icon: String { get }

    var filterName: String { get }

    var defaultIntensity: Float { get }

    var intensityRange: ClosedRange<Float> { get }

    var supportsIntensity: Bool { get }

    func parameters(intensity: Float) -> [String: Any]
}

extension ImageFilterable {

    func parameters(intensity: Float) -> [String : Any] {
        [:]
    }
    
    func apply(to image: CIImage, intensity: Float) -> CIImage? {

        guard let filter = CIFilter(name: filterName) else {
            return image
        }

        filter.setValue(image, forKey: kCIInputImageKey)
        parameters(intensity: intensity).forEach {key, value in
            filter.setValue(value, forKey: key)
        }
        return filter.outputImage
    }
}
