//
//  View.swift
//  Aurora Editor
//
//  Created by Lukas Pistrol on 22.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

internal extension View {

    /// Changes the cursor appearance when hovering attached View
    /// 
    /// - Parameters:
    ///   - active: onHover() value
    ///   - isDragging: indicate that dragging is happening. If true this will not change the cursor.
    ///   - cursor: the cursor to display on hover
    func isHovering(_ active: Bool, isDragging: Bool = false, cursor: NSCursor = .arrow) {
        if isDragging { return }
        if active {
            cursor.push()
        } else {
            NSCursor.pop()
        }
    }

    /// Font with line height
    ///
    /// - Parameter fontSize: font size
    /// - Parameter lineHeight: line height
    ///
    /// - Returns: modified content
    func fontWithLineHeight(fontSize: CGFloat, lineHeight: CGFloat) -> some View {
        ModifiedContent(
            content: self,
            modifier: FontWithLineHeight(
                font: NSFont(
                    name: "SF Pro Text",
                    size: fontSize
                ) ?? .systemFont(ofSize: fontSize),
                lineHeight: lineHeight
            )
        )
    }
}
