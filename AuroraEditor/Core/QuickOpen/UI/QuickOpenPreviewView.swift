//
//  QuickOpenPreviewView.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 20.03.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

public struct QuickOpenPreviewView: View {
    /// File item
    private let item: FileSystemClient.FileItem

    /// Code file document.
    @State
    private var codeFile: CodeFileDocument?

    /// True when preview loading is in progress.
    @State
    private var isLoading = true

    /// Preview loading error.
    @State
    private var error: String?

    /// Initialize a new QuickOpenPreviewView
    /// 
    /// - Parameter item: file item
    /// 
    /// - Returns: a new QuickOpenPreviewView
    public init(item: FileSystemClient.FileItem) {
        self.item = item
    }

    /// The view body.
    public var body: some View {
        VStack {
            if let codeFile {
                // "Quick Look" function, need to pass a empty env here as well.
                CodeEditorViewWrapper(
                    codeFile: codeFile,
                    editable: false,
                    fileExtension: item.url.pathExtension
                ).environmentObject(WorkspaceDocument())
            } else if let error = error {
                Text(error)
            } else if isLoading {
                ProgressView()
                    .accessibilityLabel(Text("Loading file preview"))
            } else {
                EmptyView()
            }
        }
        .task(id: item.url) {
            codeFile = nil
            error = nil
            isLoading = true

            do {
                codeFile = try CodeFileDocument(
                    for: item.url,
                    withContentsOf: item.url,
                    ofType: item.url.pathExtension
                )
            } catch let error {
                self.error = error.localizedDescription
            }

            isLoading = false
        }
    }
}
