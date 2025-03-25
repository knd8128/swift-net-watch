//
//  UIWindow+ShakeDetection.swift
//  SwiftNetWatch
//
//  Created by Abraham Rubio on 05/03/25.
//

import UIKit

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        guard motion == .motionShake else {
            super.motionEnded(motion, with: event)
            return
        }

        SwiftNetWatch.shared.showOverlay()
    }
}
