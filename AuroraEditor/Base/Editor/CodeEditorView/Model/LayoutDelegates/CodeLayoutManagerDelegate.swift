//
//  CodeLayoutManagerDelegate.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 18/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import AppKit

/// Delegate for the layout manager.
class CodeLayoutManagerDelegate: NSObject, NSLayoutManagerDelegate {

    /// Layout manager
    /// 
    /// - Parameter layoutManager: layout manager
    /// - Parameter textContainer: text container
    /// - Parameter proposedRect: proposed rect
    func layoutManager(_ layoutManager: NSLayoutManager,
                       didCompleteLayoutFor textContainer: NSTextContainer?,
                       atEnd layoutFinishedFlag: Bool) {
        guard let layoutManager = layoutManager as? CodeLayoutManager else { return }

        if layoutFinishedFlag { layoutManager.gutterView?.layoutFinished() }
    }
}
