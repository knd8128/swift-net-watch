//
//  NetworkLogger.swift
//  SwiftNetWatch
//
//  Created by Abraham Rubio on 05/03/25.
//

import Foundation

class NetworkLogger: ObservableObject {
    static let shared = NetworkLogger()
    public init() {}

    @Published public var logs: [NetworkLog] = []
    
    func log(request: URLRequest, response: URLResponse?, data: Data?) {
        let url = request.url?.absoluteString ?? "N/A"
        let method = request.httpMethod ?? "N/A"
        let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

        
        let requestBody: String = {
            if let httpBody = request.httpBody, !httpBody.isEmpty {
                let body = String(data: httpBody, encoding: .utf8) ?? ""
                return body.isEmpty ? "N/A" : body
            } else if let stream = request.httpBodyStream {
                stream.open()
                let bufferSize = 1024
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                var dataFromStream = Data()
                while stream.hasBytesAvailable {
                    let read = stream.read(buffer, maxLength: bufferSize)
                    if read <= 0 { break }
                    dataFromStream.append(buffer, count: read)
                }
                buffer.deallocate()
                stream.close()
                let bodyString = String(data: dataFromStream, encoding: .utf8) ?? ""
                return bodyString.isEmpty ? "N/A" : bodyString
            }
            return "N/A"
        }()

        
        let responseBody: String = {
            if let responseData = data, !responseData.isEmpty {
                let s = String(data: responseData, encoding: .utf8) ?? ""
                return s.isEmpty ? "N/A" : s
            }
            return "N/A"
        }()

        
        let requestHeaders = request.allHTTPHeaderFields ?? [:]
        let responseHeaders = (response as? HTTPURLResponse)?.allHeaderFields as? [String: String] ?? [:]

        
        let requestQuery: [String: String]? = {
            if let query = request.url?.query {
                let dict = query.split(separator: "&").reduce(into: [String: String]()) { dict, pair in
                    let components = pair.split(separator: "=")
                    if components.count == 2 {
                        dict[String(components[0])] = String(components[1])
                    }
                }
                return dict.isEmpty ? ["N/A": "N/A"] : dict
            }
            return ["N/A": "N/A"]
        }()

        
        var rawRequest = "\(method) \(url) HTTP/1.1\n"
        rawRequest += requestHeaders.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
        rawRequest += "\n\n" + (requestBody.isEmpty ? "N/A" : requestBody)

        
        var rawResponse = "HTTP/1.1 \(statusCode)\n"
        rawResponse += responseHeaders.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
        rawResponse += "\n\n" + (responseBody.isEmpty ? "N/A" : responseBody)

        
        let responseTime: TimeInterval = Date().timeIntervalSince1970 - (request.httpBody?.count ?? 0).toTimeInterval()

        
        let log = NetworkLog(
            url: url,
            method: method,
            statusCode: statusCode,
            responseTime: responseTime,
            requestBody: requestBody,
            responseBody: responseBody,
            requestHeaders: requestHeaders,
            responseHeaders: responseHeaders,
            requestQuery: requestQuery,
            rawRequest: rawRequest,
            rawResponse: rawResponse,
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            self.logs.insert(log, at: 0)
        }
    }
}

private extension Int {
    func toTimeInterval() -> TimeInterval {
        return TimeInterval(self) / 1000.0
    }
}
