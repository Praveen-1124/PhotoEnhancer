//
//  FilterRegistry.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 12/05/26.
//

import Foundation

enum FilterRegistry {

    static let all: [ImageFilterable] = [
        OriginalFilter(),
        ChromeFilter(),
        FadeFilter(),
        InstantFilter(),
        MonoFilter(),
        NoirFilter(),
        ProcessFilter(),
        TonalFilter(),
        TransferFilter(),
        SepiaFilter(),
        InvertFilter(),
        VignetteFilter(),
        BloomFilter(),
        CrystallizeFilter(),
        ComicFilter(),
        PixelateFilter()
    ]
}
