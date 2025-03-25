//
//  NetworkInterceptor.swift
//  SwiftNetWatch
//
//  Created by Abraham Rubio on 05/03/25.
//

import Foundation

public class NetworkInterceptor: URLProtocol {
    private var sessionTask: URLSessionDataTask?
    private var session: URLSession?
    
    private static let handledKey = "InterceptorHandled"
    
    override public class func canInit(with request: URLRequest) -> Bool {
        
        guard let scheme = request.url?.scheme?.lowercased(), (scheme == "http" || scheme == "https") else {
            return false
        }
        
        if URLProtocol.property(forKey: handledKey, in: request) != nil {
            return false
        }
        return true
    }
    
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override public func startLoading() {
        
        let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: NetworkInterceptor.handledKey, in: mutableRequest)
        
        
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        
        if var protocols = configuration.protocolClasses {
            protocols.insert(NetworkInterceptor.self, at: 0)
            configuration.protocolClasses = protocols
        } else {
            configuration.protocolClasses = [NetworkInterceptor.self]
        }
        
        self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
        
        sessionTask = session?.dataTask(with: mutableRequest as URLRequest, completionHandler: { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let response = response {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let data = data {
                self.client?.urlProtocol(self, didLoad: data)
                
                NetworkLogger.shared.log(request: self.request, response: response, data: data)
            }
            if let error = error {
                self.client?.urlProtocol(self, didFailWithError: error)
            } else {
                self.client?.urlProtocolDidFinishLoading(self)
            }
        })
        sessionTask?.resume()
    }
    
    override public func stopLoading() {
        sessionTask?.cancel()
        session = nil
    }
}
