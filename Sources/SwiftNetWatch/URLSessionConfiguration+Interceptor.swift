//
//  URLSessionConfiguration+Interceptor.swift
//  SwiftNetWatch
//
//  Created by Abraham Rubio on 05/03/25.
//

import Foundation

extension URLSessionConfiguration {
    private static let swizzleDefaultConfiguration: Void = {
        let originalSelector = #selector(getter: URLSessionConfiguration.default)
        let swizzledSelector = #selector(URLSessionConfiguration.myDefaultConfiguration)
        
        guard let originalMethod = class_getClassMethod(URLSessionConfiguration.self, originalSelector),
              let swizzledMethod = class_getClassMethod(URLSessionConfiguration.self, swizzledSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()
    
    @objc class func myDefaultConfiguration() -> URLSessionConfiguration {
        let config = myDefaultConfiguration()
        var protocols = config.protocolClasses ?? []
        if !protocols.contains(where: { $0 == NetworkInterceptor.self }) {
            protocols.insert(NetworkInterceptor.self, at: 0)
            config.protocolClasses = protocols
        }
        return config
    }
    
    public static func enableInterceptorSwizzling() {
        _ = self.swizzleDefaultConfiguration
    }
}
