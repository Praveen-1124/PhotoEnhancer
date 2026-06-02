//
//  Extensions.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 25/05/26.
//

import Foundation

//MARK: - Optional

extension Optional where Wrapped == String {

    var orEmpty: String {
        return self ?? ""
    }
}

//MARK: - String

extension String {

    var toDouble: Double {
        return Double(self) ?? 0.0
    }

    var toInt: Int {
        return Int(self) ?? 0
    }
}

//------------------------------------------EOF---------------------------------------------------------------------
