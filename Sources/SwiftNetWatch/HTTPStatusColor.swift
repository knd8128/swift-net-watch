//
//  HTTPStatusColor.swift
//  SwiftNetWatch
//
//  Created by Abraham Rubio on 05/03/25.
//

import Foundation
import SwiftUI

enum HTTPStatusColor {
    
    case informational  // 1xx
    case success        // 2xx
    case redirection    // 3xx
    case clientError    // 4xx
    case serverError    // 5xx
    case unknown        // Others

    var color: Color {
        switch self {
        case .informational: return Color.blue
        case .success: return Color.green
        case .redirection: return Color.yellow
        case .clientError: return Color.orange
        case .serverError: return Color.red
        case .unknown: return Color.gray
        }
    }

    static func from(statusCode: Int) -> HTTPStatusColor {
        switch statusCode {
        case 100..<200: return .informational
        case 200..<300: return .success
        case 300..<400: return .redirection
        case 400..<500: return .clientError
        case 500..<600: return .serverError
        default: return .unknown
        }
    }
}
