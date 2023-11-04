//
//  TabBarItemRepresentable.swift
//  Aurora Editor
//
//  Created by Pavel Kasila on 30.04.22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This file originates from CodeEdit, https://github.com/CodeEditApp/CodeEdit

import SwiftUI

/// Protocol for data passed to TabBarItem to conform to
public protocol TabBarItemRepresentable {
    /// Unique tab identifier
    var tabID: TabBarItemID { get }
    /// String to be shown as tab's title
    var title: String { get }
    /// Image to be shown as tab's icon
    var icon: Image { get }
    /// Color of the tab's icon
    var iconColor: Color { get }
}
