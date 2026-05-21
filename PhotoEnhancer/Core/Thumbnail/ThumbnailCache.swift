//
//  ThumbnailCache.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 13/05/26.
//

import UIKit

final class ThumbnailCache {

    static let shared = ThumbnailCache()
    private let cache = NSCache<NSString, UIImage>()

    private init() {

    }

    func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func store(image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}
