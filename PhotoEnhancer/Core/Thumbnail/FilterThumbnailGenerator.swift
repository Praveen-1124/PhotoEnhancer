//
//  FilterThumbnailGenerator.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation
import UIKit
import CoreImage

final class FilterThumbnailGenerator {

    static let shared = FilterThumbnailGenerator()
    private let queue = DispatchQueue(label:"filter.thumbnail.queue", qos: .utility)

    private init() {

    }

    func generateThumbnail(image: CIImage, filter: ImageFilterable, completion: @escaping (UIImage?) -> Void) {

        ThumbnailCache.shared.clearCache()
        let cacheKey = filter.id // Cache Key
        //        if let cached = ThumbnailCache.shared.image(for: cacheKey) { // Cached Image
        //            completion(cached)
        //            return
        //        }

        queue.async {
            autoreleasepool {
                let thumbnail = ImageRenderer.shared.generateThumbnail(image: image, filter: filter)
                ThumbnailCache.shared.store(image: thumbnail, for: cacheKey)
                DispatchQueue.main.async {
                    completion(thumbnail)
                }
            }
        }
    }
}
