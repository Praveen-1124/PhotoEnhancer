//
//  TransferFilter.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation

struct TransferFilter: ImageFilterable {

    let id = "transfer"
    let title = "Transfer"
    let icon = "wand.and.stars"
    let filterName = "CIPhotoEffectTransfer"
    let supportsIntensity = false
    let defaultIntensity: Float = 1
    let intensityRange: ClosedRange<Float> = 0...1
}
