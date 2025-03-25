//
//  SwiftNetWatchView.swift
//  SwiftNetWatch
//
//  Created by Abraham Rubio on 05/03/25.
//

import SwiftUI

public struct SwiftNetWatchView: View {
    @ObservedObject var logger: NetworkLogger = .shared
    @State var isShowingAlert: Bool = false
    @State var searchText: String = ""
    
    var logs: [NetworkLog] = []
    
    var searchResults: [NetworkLog] {
        if searchText.isEmpty {
            return logger.logs
        } else {
            return logger.logs.filter{$0.url.contains(searchText.lowercased())}
        }
    }

    public var body: some View {
        NavigationView {
            List(searchResults) { log in
                NavigationLink(destination: LogDetailView(log: log)) {
                    HStack {
                        Circle()
                            .frame(width: 20, height: 20)
                            .foregroundColor(log.statusColor)
                            .padding(.trailing, 10)
                        VStack(alignment: .leading) {
                            Text(log.url)
                                .font(.subheadline)
                                .lineLimit(2)
                            Text("**Method:** \(log.method)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("**Status Code:** \(log.statusCode)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            HStack(spacing: 0) {
                                Text("**Time:** ")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(log.timestamp, format: .dateTime.hour().minute().second())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("SwiftNetWatch")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        SwiftNetWatch.shared.closeOverlay()
                    } label: {
                        Text("Close")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingAlert.toggle()
                    } label: {
                        Text("Clear")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        Text("Settings")
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .alert("Clear all logs", isPresented: $isShowingAlert) {
                Button("Yes") {
                    logger.logs.removeAll()
                }
                Button("Cancel", role: .cancel) {
                    isShowingAlert.toggle()
                }
            } message: {
                Text("Are you sure you want to clear logs?")
            }
        }
    }
}

struct LogDetailView: View {
    let log: NetworkLog
    @State private var selectedRequestTab = 0
    @State private var selectedResponseTab = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                // MARK: - Request Section
                HStack {
                    Image(systemName: "icloud.and.arrow.up")
                    Text("Request").font(.headline)
                }
                
                Picker("", selection: $selectedRequestTab) {
                    Text("Headers").tag(0)
                    Text("Query").tag(1)
                    Text("Body").tag(2)
                    Text("Raw").tag(3)
                }
                .pickerStyle(.segmented)

                if selectedRequestTab == 0 {
                    KeyValueView(data: log.requestHeaders)
                } else if selectedRequestTab == 1 {
                    KeyValueView(data: log.requestQuery ?? [:])
                } else if selectedRequestTab == 2 {
                    JSONTextView(jsonString: log.requestBody ?? "N/A")
                } else {
                    RawTextView(rawText: log.rawRequest)
                }

                Divider()

                // MARK: - Response Section
                HStack {
                    Image(systemName: "icloud.and.arrow.down")
                    Text("Response").font(.headline)
                }
                
                Picker("", selection: $selectedResponseTab) {
                    Text("Headers").tag(0)
                    Text("Body").tag(1)
                    Text("Raw").tag(2)
                }
                .pickerStyle(.segmented)

                if selectedResponseTab == 0 {
                    KeyValueView(data: log.responseHeaders)
                } else if selectedResponseTab == 1 {
                    JSONTextView(jsonString: log.responseBody ?? "N/A")
                } else {
                    RawTextView(rawText: log.rawResponse)
                }
            }
            .padding()
        }
        .navigationTitle("Details")
    }
}

// MARK: - Headers y Query View
struct KeyValueView: View {
    let data: [String: String]

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(data.keys.sorted(), id: \.self) { key in
                HStack {
                    Text(key).bold()
                    Spacer()
                    Text(data[key] ?? "")
                }
                Divider()
            }
        }
        .font(.footnote)
        .padding()
    }
}

// MARK: - Pretty JSON View
struct JSONTextView: View {
    let jsonString: String

    var body: some View {
        ScrollView {
            Text(jsonString.prettyJSON() ?? jsonString)
                .multilineTextAlignment(.leading)
                .font(.system(.footnote, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity)
        }
        .background(Color.black.opacity(0.05))
        .cornerRadius(5)
    }
}

// MARK: - Raw Data
struct RawTextView: View {
    let rawText: String

    var body: some View {
        ScrollView {
            Text(rawText)
                .multilineTextAlignment(.leading)
                .font(.system(.footnote, design: .monospaced))
                .padding()
                .frame(maxWidth: .infinity)
        }
        .background(Color.black.opacity(0.05))
        .cornerRadius(5)
    }
}

// MARK: - Pretty JSON Extension
extension String {
    func prettyJSON() -> String? {
        guard let data = self.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let formattedData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
              let formattedString = String(data: formattedData, encoding: .utf8) else {
            return nil
        }
        return formattedString
    }
}

// MARK: - Preview
#Preview {
    let logs = [
        NetworkLog(
            url: "https://api.example.com/data",
            method: "GET",
            statusCode: 200,
            responseTime: 0.35,
            requestBody: nil,
            responseBody: "{ \"message\": \"Success\" }",
            requestHeaders: ["Authorization": "Bearer token123", "Content-Type": "application/json"],
            responseHeaders: ["Server": "Apache", "Content-Type": "application/json"],
            requestQuery: ["id": "42", "filter": "active"],
            rawRequest: "GET /data?id=42&filter=active HTTP/1.1\nAuthorization: Bearer token123\n...",
            rawResponse: "HTTP/1.1 200 OK\nServer: Apache\nContent-Type: application/json\n\n{\"message\": \"Success\"}",
            timestamp: Date()
        ),
        NetworkLog(
            url: "https://api.google.com/login",
            method: "POST",
            statusCode: 401,
            responseTime: 0.50,
            requestBody: "{ \"username\": \"test\", \"password\": \"****\" }",
            responseBody: "{ \"error\": \"Unauthorized\" }",
            requestHeaders: ["Content-Type": "application/json"],
            responseHeaders: ["Server": "nginx", "Content-Type": "application/json"],
            requestQuery: nil,
            rawRequest: "POST /login HTTP/1.1\nContent-Type: application/json\n...",
            rawResponse: "HTTP/1.1 401 Unauthorized\nServer: nginx\nContent-Type: application/json\n\n{\"error\": \"Unauthorized\"}",
            timestamp: Date()
        )
    ]

    SwiftNetWatchView(logs: logs)
}
