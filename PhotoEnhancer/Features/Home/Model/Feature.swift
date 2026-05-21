//
//  Feature.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 13/05/26.
//

import Foundation

enum Feature: CaseIterable {

    case camera
    case photoFilters
    case backgroundRemover
//    case objectRemover
    case photoUpscaler

    var title: String {
        switch self {
        case .camera:
            return "Camera"

        case .photoFilters:
            return "Filters"

        case .backgroundRemover:
            return "Background Remover"

//        case .objectRemover:
//            return "Object Remover"

        case .photoUpscaler:
            return "Photo Upscaling"
        }
    }

}
