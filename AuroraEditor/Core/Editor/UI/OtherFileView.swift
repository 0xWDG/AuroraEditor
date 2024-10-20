//
//  OtherFileView.swift
//  Aurora Editor
//
//  Created by Shibo Tong on 10/7/2022.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import QuickLookUI

/// A SwiftUI Wrapper for `QLPreviewView`
/// Mainly used for other unsupported files
///
/// ## Usage
/// ```swift
/// OtherFileView(otherFile)
/// ```
public struct OtherFileView: NSViewRepresentable {
    /// The file to preview
    private var otherFile: CodeFileDocument

    /// Initialize the OtherFileView
    /// 
    /// - Parameter otherFile: a file which contains URL to show preview
    public init(
        _ otherFile: CodeFileDocument
    ) {
        self.otherFile = otherFile
    }

    /// Create a QLPreviewView
    /// 
    /// - Parameter context: context
    /// 
    /// - Returns: a QLPreviewView
    public func makeNSView(context: Context) -> QLPreviewView {
        let qlPreviewView = QLPreviewView()
        if let previewItemURL = otherFile.previewItemURL {
            qlPreviewView.previewItem = previewItemURL as QLPreviewItem
        }
        return qlPreviewView
    }

    /// Update preview file when file changed
    /// 
    /// - Parameter nsView: QLPreviewView
    /// - Parameter context: context
    public func updateNSView(_ nsView: QLPreviewView, context: Context) {
        guard let currentPreviewItem = nsView.previewItem else { return }
        if let previewItemURL = otherFile.previewItemURL, previewItemURL != currentPreviewItem.previewItemURL {
            nsView.previewItem = previewItemURL as QLPreviewItem
        }
    }
}
