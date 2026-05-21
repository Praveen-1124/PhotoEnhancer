//
//  CameraFilter.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 13/05/26.
//

import UIKit
import CoreImage

enum CameraFilter: CaseIterable {

    case original
    case vivid
    case vividCool
    case vividWarm
    case dramatic
    case noir
    case silvertone
    case mono

    var title: String {

        switch self {

        case .original: return "Original"
        case .vivid: return "Vivid"
        case .vividCool: return "Cool"
        case .vividWarm: return "Warm"
        case .dramatic: return "Dramatic"
        case .noir: return "Noir"
        case .silvertone: return "Silver"
        case .mono: return "Mono"
        }
    }

    func makeFilters() -> [CIFilter] {

        switch self {

        case .original:
            return []
        case .vivid:
            let controls = CIFilter(name: "CIColorControls")!
            controls.setValue(1.3, forKey: kCIInputSaturationKey)
            controls.setValue(1.1, forKey: kCIInputContrastKey)
            return [controls]
        case .vividCool:
            let controls = CIFilter(name: "CIColorControls")!
            controls.setValue(1.25, forKey: kCIInputSaturationKey)

            let temp = CIFilter(name: "CITemperatureAndTint")!
            temp.setValue(CIVector(x: 6500, y: 0), forKey: "inputNeutral")
            temp.setValue(CIVector(x: 8500, y: 0), forKey: "inputTargetNeutral")

            return [controls, temp]
        case .vividWarm:
            let controls = CIFilter(name: "CIColorControls")!
            controls.setValue(1.2, forKey: kCIInputSaturationKey)

            let temp = CIFilter(name: "CITemperatureAndTint")!
            temp.setValue( CIVector(x: 6500, y: 0), forKey: "inputNeutral")
            temp.setValue(CIVector(x: 4500, y: 0), forKey: "inputTargetNeutral")

            return [controls, temp]
        case .dramatic:
            let controls = CIFilter(name: "CIColorControls")!
            controls.setValue(1.2, forKey: kCIInputContrastKey)

            let shadow = CIFilter(name: "CIHighlightShadowAdjust")!
            shadow.setValue(-0.5, forKey: "inputShadowAmount")
            return [controls, shadow]
        case .noir:
            let noir = CIFilter(name: "CIPhotoEffectNoir")!
            return [noir]
        case .silvertone:
            let controls = CIFilter(name: "CIColorControls")!
            controls.setValue(0.25, forKey: kCIInputSaturationKey)
            return [controls]
        case .mono:
            let mono = CIFilter(name: "CIPhotoEffectMono")!
            return [mono]
        }
    }
}
