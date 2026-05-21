//
//  EditorState.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation

struct EditorState {

    var selectedFilterID: String?
    var filterIntensityMap: [String: Float] = [:]
    var adjustmentIntensityMap: [String: Float] = [:]
}
