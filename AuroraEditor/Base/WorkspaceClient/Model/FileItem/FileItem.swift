//
//  FileItem.swift
//  AuroraEditorModules/WorkspaceClient
//
//  Created by Marco Carnevali on 16/03/22.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

public extension WorkspaceClient {
    enum FileItemCodingKeys: String, CodingKey {
        case id
        case url
        case children
        case changeType
    }

    /// An object containing all necessary information and actions for a specific file in the workspace
    final class FileItem: Identifiable, Codable, TabBarItemRepresentable {
        public var tabID: TabBarItemID { .codeEditor(id) }

        public var title: String { url.lastPathComponent }

        public var icon: Image { Image(systemName: systemImage) }

        public var shouldBeExpanded: Bool = false

        public typealias ID = String

        public var fileIdentifier = UUID().uuidString

        public var watcher: DispatchSourceFileSystemObject?
        public var watcherCode: () -> Void = {}

        public func activateWatcher() -> Bool {
            let descriptor = open(self.url.path, O_EVTONLY)
            guard descriptor > 0 else { return false }
            let source = DispatchSource.makeFileSystemObjectSource(
                fileDescriptor: descriptor,
                eventMask: .write,
                queue: DispatchQueue.global()
            )
            if descriptor > 2000 {
                Log.info("Watcher \(descriptor) used up")
            }
            source.setEventHandler { self.watcherCode() }
            source.setCancelHandler { close(descriptor) }
            source.resume()
            self.watcher = source
            return true
        }

        public init(url: URL,
                    children: [FileItem]? = nil,
                    changeType: GitType? = nil) {
            self.url = url
            self.children = children
            self.changeType = changeType
            id = url.relativePath
        }

        public required init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: FileItemCodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            url = try values.decode(URL.self, forKey: .url)
            children = try values.decode([FileItem]?.self, forKey: .children)
            changeType = try values.decode(GitType.self, forKey: .changeType)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: FileItemCodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(url, forKey: .url)
            try container.encode(children, forKey: .children)
            try container.encode(changeType, forKey: .changeType)
        }

        /// The id of the ``WorkspaceClient/WorkspaceClient/FileItem``.
        ///
        /// This is equal to `url.relativePath`
        public var id: ID

        /// Returns the URL of the ``WorkspaceClient/WorkspaceClient/FileItem``
        public var url: URL

        /// Returns the children of the current ``WorkspaceClient/WorkspaceClient/FileItem``.
        ///
        /// If the current ``WorkspaceClient/WorkspaceClient/FileItem`` is a file this will be `nil`.
        /// If it is an empty folder this will be an empty array.
        public var children: [FileItem]?

        /// Returns a parent ``WorkspaceClient/WorkspaceClient/FileItem``.
        ///
        /// If the item already is the top-level ``WorkspaceClient/WorkspaceClient/FileItem`` this returns `nil`.
        public var parent: FileItem?

        public let changeType: GitType?

        /// A boolean that is true if ``children`` is not `nil`
        public var isFolder: Bool {
            children != nil
        }

        /// A boolean that is true if the file item is the root folder of the workspace.
        public var isRoot: Bool {
            parent == nil
        }

        /// Returns a string describing a SFSymbol for the current ``WorkspaceClient/WorkspaceClient/FileItem``
        ///
        /// Use it like this
        /// ```swift
        /// Image(systemName: item.systemImage)
        /// ```
        public var systemImage: String {
            switch children {
            case nil:
                return FileIcon.fileIcon(fileType: fileType)
            case let .some(children):
                // check if there is no filter so that when searching, if a bunch of cache files
                // pop up, such as ones in node_modules, we don't want to watch them. 
                if self.watcher == nil && !self.activateWatcher() && WorkspaceClient.filter.isEmpty {
                    return "questionmark.folder"
                }
                return folderIcon(children)
            }
        }

        /// Returns the file name (e.g.: `Package.swift`)
        public var fileName: String {
            url.lastPathComponent
        }

        /// Returns the extension of the file or an empty string if no extension is present.
        public var fileType: FileIcon.FileType {
            .init(rawValue: url.pathExtension) ?? .txt
        }

        /// Returns a string describing a SFSymbol for folders
        ///
        /// If it is the top-level folder this will return `"square.dashed.inset.filled"`.
        /// If it is a `.codeedit` folder this will return `"folder.fill.badge.gearshape"`.
        /// If it has children this will return `"folder.fill"` otherwise `"folder"`.
        private func folderIcon(_ children: [FileItem]) -> String {
            if self.parent == nil {
                return "square.dashed.inset.filled"
            }
            if self.fileName == ".codeedit" {
                return "folder.fill.badge.gearshape"
            }
            return children.isEmpty ? "folder" : "folder.fill"
        }

        /// Returns the file name with optional extension (e.g.: `Package.swift`)
        public func fileName(typeHidden: Bool) -> String {
            typeHidden ? url.deletingPathExtension().lastPathComponent : fileName
        }

        /// Return the file's UTType
        public var contentType: UTType? {
            try? url.resourceValues(forKeys: [.contentTypeKey]).contentType
        }

        /// Returns a `Color` for a specific `fileType`
        ///
        /// If not specified otherwise this will return `Color.accentColor`
        public var iconColor: Color {
            FileIcon.iconColor(fileType: fileType)
        }

        public var changeTypeValue: String {
            changeType?.description ?? ""
        }

        // MARK: Statics
        /// The default `FileManager` instance
        public static let fileManger = FileManager.default

        // MARK: Intents
        /// Allows the user to view the file or folder in the finder application
        public func showInFinder() {
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }

        /// Allows the user to launch the file or folder as it would be in finder
        public func openWithExternalEditor() {
            NSWorkspace.shared.open(url)
        }

        public func flattenedChildren(depth: Int, ignoringFolders: Bool) -> [FileItem] {
            guard depth > 0 else { return [] }
            guard isFolder else { return [self] }
            var childItems: [FileItem] = ignoringFolders ? [] : [self]
            children?.forEach { child in
                childItems.append(contentsOf: child.flattenedChildren(depth: depth-1,
                    ignoringFolders: ignoringFolders))
            }
            return childItems
        }

        public func flattenedSiblings(height: Int, ignoringFolders: Bool) -> [FileItem] {
            var topmostParent = self
            for _ in 0..<height {
                guard let parent = topmostParent.parent else { break }
                topmostParent = parent
            }
            return topmostParent.flattenedChildren(depth: height, ignoringFolders: ignoringFolders)
        }

        /// Recursive function that returns the number of children
        /// that contain the `searchString` in their path or their subitems' paths.
        /// Returns `0` if the item is not a folder.
        /// - Parameter searchString: The string
        /// - Returns: The number of children that match the conditiions
        public func appearanceWithinChildrenOf(searchString: String,
                                               ignoreDots: Bool = true,
                                               ignoreTilde: Bool = true) -> Int {
            var count = 0
            guard self.isFolder else { return 0 }
            for child in self.children ?? [] {
                if ignoreDots && child.fileName.starts(with: ".") { continue }
                if ignoreTilde && child.fileName.starts(with: "~") { continue }
                guard !searchString.isEmpty else { count += 1; continue }
                if child.isFolder {
                    count += child.appearanceWithinChildrenOf(searchString: searchString) > 0 ? 1 : 0
                } else {
                    count += child.fileName.lowercased().contains(searchString.lowercased()) ? 1 : 0
                }
            }
            return count
        }

        /// Function that returns an array of the children
        /// that contain the `searchString` in their path or their subitems' paths.
        /// Similar to `appearanceWithinChildrenOf(searchString: String)`
        /// Returns `[]` if the item is not a folder.
        /// - Parameter searchString: The string
        /// - Returns: The children that match the conditiions
        public func childrenSatisfying(searchString: String,
                                       ignoreDots: Bool = true,
                                       ignoreTilde: Bool = true) -> [FileItem] {
            var satisfyingChildren: [FileItem] = []
            guard self.isFolder else { return [] }
            for child in self.children ?? [] {
                if ignoreDots && child.fileName.starts(with: ".") { continue }
                if ignoreTilde && child.fileName.starts(with: "~") { continue }
                guard !searchString.isEmpty else { satisfyingChildren.append(child); continue }
                if child.isFolder {
                    if child.appearanceWithinChildrenOf(searchString: searchString) > 0 {
                        satisfyingChildren.append(child)
                    }
                } else {
                    if child.fileName.lowercased().contains(searchString.lowercased()) {
                        satisfyingChildren.append(child)
                    }
                }
            }
            return satisfyingChildren
        }
    }
}

// MARK: Hashable
extension WorkspaceClient.FileItem: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(fileIdentifier)
        hasher.combine(id)
    }
}

// MARK: Comparable
extension WorkspaceClient.FileItem: Comparable {
    public static func == (lhs: WorkspaceClient.FileItem, rhs: WorkspaceClient.FileItem) -> Bool {
        lhs.id == rhs.id
    }

    public static func < (lhs: WorkspaceClient.FileItem, rhs: WorkspaceClient.FileItem) -> Bool {
        lhs.url.lastPathComponent < rhs.url.lastPathComponent
    }
}
