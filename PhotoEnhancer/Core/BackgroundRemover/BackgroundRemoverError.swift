//
//  BackgroundRemoverError.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 14/05/26.
//

import Foundation

enum BackgroundRemoverError: Error {
    
    case invalidImage
    case maskGenerationFailed
    case renderFailed
    case downsamplingFailed
}
