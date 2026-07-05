//
//  WorkspaceExtension.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/09/06.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

extension WorkspaceDocument {
    /// Workspace URL
    /// 
    /// - Returns: workspace URL
    @available(*, deprecated, renamed: "folderURL")
    func workspaceURL() -> URL {
        folderURL
    }
}
