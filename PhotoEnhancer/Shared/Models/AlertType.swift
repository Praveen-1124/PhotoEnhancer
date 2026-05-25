//
//  AlertType.swift
//  PhotoEnhancer
//
//  Created by Praveen A on 25/05/26.
//

import Foundation

enum AlertType {
    case info
    case success
    case error
    case warning

    var title: String {
        switch self {
        case .info:
            return "Info"
        case .success:
            return "Success"
        case .error:
            return "Error"
        case .warning:
            return "Warning"
        }
    }
}
