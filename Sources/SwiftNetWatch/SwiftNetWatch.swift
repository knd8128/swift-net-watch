//
//  SwiftNetWatch.swift
//  SwiftNetWatch
//
//  Created by Abraham Rubio on 05/03/25.
//

import UIKit
import SwiftUI

public class SwiftNetWatch {
    public static let shared = SwiftNetWatch()
    
    private var isStarted = false
    private var logWindow: UIWindow?

    private init() {}

    public func start() {
        guard !isStarted else { return }
        isStarted = true

        URLSessionConfiguration.enableInterceptorSwizzling()
        URLProtocol.registerClass(NetworkInterceptor.self)
    }
    
    func showOverlay() {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            
            let window = UIWindow(windowScene: scene)
            let controller = UIHostingController(rootView: SwiftNetWatchView())

            window.rootViewController = controller
            window.windowLevel = .alert + 2
            window.makeKeyAndVisible()

            self.logWindow = window
        }
    }
    
    func closeOverlay() {
        DispatchQueue.main.async {
            self.logWindow?.isHidden = true
            self.logWindow = nil
        }
    }
}
