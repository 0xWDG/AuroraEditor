//
//  InspectorSidebar.swift
//  Aurora Editor
//
//  Created by Austin Condiff on 3/21/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI

// The main Inspector View that handles showing the different
// views that the inspector has like the file inspector, history and
// Quick Help.
struct InspectorSidebar: View {
    /// The active state of the control
    @Environment(\.controlActiveState)
    private var activeState

    /// The workspace
    @EnvironmentObject
    private var workspace: WorkspaceDocument

    /// The current selection
    @State
    private var selection: Int = 0

    /// The preferences model
    let prefs: AppPreferencesModel

    /// The view body
    var body: some View {
        VStack {
            if let selectedItem = selectedFileItem {
                switch selection {
                case 0:
                    FileInspectorView(
                        workspaceURL: workspace.documentURL,
                        fileURL: selectedItem.url.path
                    )
                    .frame(maxWidth: .infinity)
                case 1:
                    HistoryInspector(
                        workspaceURL: workspace.documentURL,
                        fileURL: selectedItem.url.path
                    )
                case 2:
                    QuickHelpInspector().padding(5)
                default:
                    NoSelectionView()
                }
            } else {
                NoSelectionView()
            }
        }
        .frame(minWidth: 250, idealWidth: 260, minHeight: 0, maxHeight: .infinity, alignment: .top)
        .isHidden(!prefs.preferences.general.keepInspectorSidebarOpen)
        .safeAreaInset(edge: .top) {
            InspectorSidebarToolbarTop(selection: $selection)
                .padding(.bottom, -8)
        }
        .background(
            EffectView(.windowBackground, blendingMode: .withinWindow)
        )
        .opacity(activeState == .inactive ? 0.45 : 1)
    }

    /// The selected file item
    private var selectedFileItem: FileItem? {
        guard let selectedId = workspace.selectionState.selectedId else { return nil }
        return workspace.selectionState.openFileItems.first { $0.tabID == selectedId }
    }
}
