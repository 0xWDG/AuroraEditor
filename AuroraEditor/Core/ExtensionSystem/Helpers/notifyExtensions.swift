//
//  notifyExtensions.swift
//  Aurora Editor
//
//  Created by Wesley de Groot on 27/08/2024.
//  Copyright © 2024 Aurora Company. All rights reserved.
//

import SwiftUI

extension View {
    /// On Appear & Disappear notification for extensions
    ///
    /// - Parameter name: Name of element
    /// - Parameter appear: On appear parameters
    /// - Parameter disappear: On disappear parameters
    /// 
    /// - Returns: The current view.
    public func notifyExtensions(
        name: String,
        appear: [String: Any] = [:],
        disappear: [String: Any] = [:]
    ) -> some View {

        return self
            .onAppear {
                ExtensionsManager.shared.sendEvent(
                    event: "\(name)DidAppear",
                    parameters: appear
                )
            }
            .onDisappear {
                ExtensionsManager.shared.sendEvent(
                    event: "\(name)DidDisppear",
                    parameters: disappear
                )
            }
    }
}
