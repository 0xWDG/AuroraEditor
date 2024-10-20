//
//  WorkflowCellView.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import SwiftUI
import Version_Control

struct WorkflowCellView: View {

    @State
    var workflow: Workflow

    var body: some View {
        HStack {
            Image(systemName: "diamond")
                .accessibilityHidden(true)

            VStack(alignment: .leading) {
                Text(workflow.name)
                    .font(.system(size: 11, weight: .medium))

                Text(workflow.path)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 10)
    }
}
