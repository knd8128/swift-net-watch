import SwiftUI

struct NetworkLog: Identifiable {
    
    public let id = UUID()
    public let url: String
    public let method: String
    public let statusCode: Int
    public let responseTime: TimeInterval
    public let requestBody: String?
    public let responseBody: String?
    public let requestHeaders: [String: String]
    public let responseHeaders: [String: String]
    public let requestQuery: [String: String]?
    public let rawRequest: String
    public let rawResponse: String
    public let timestamp: Date

    var statusColor: Color {
        HTTPStatusColor.from(statusCode: statusCode).color
    }
}
