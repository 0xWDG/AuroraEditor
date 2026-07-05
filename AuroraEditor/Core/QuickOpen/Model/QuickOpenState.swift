//
//  QuickOpenState.swift
//  Aurora Editor
//
//  Created by Marco Carnevali on 05/04/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Combine
import Foundation

/// Quick open state
@MainActor
public final class QuickOpenState: ObservableObject {
    /// Open quickly query
    @Published
    var openQuicklyQuery: String = ""

    /// Open quickly files
    @Published
    var openQuicklyFiles: [FileSystemClient.FileItem] = []

    /// Is showing open quickly files
    @Published
    var isShowingOpenQuicklyFiles: Bool = false

    /// File URL
    public let fileURL: URL

    /// Current search task.
    private var searchTask: Task<Void, Never>?

    /// Initialize a new QuickOpenState
    /// 
    /// - Parameter fileURL: file URL
    /// 
    /// - Returns: a new QuickOpenState
    public init(fileURL: URL) {
        self.fileURL = fileURL
    }

    /// Fetch open quickly
    func fetchOpenQuickly() {
        searchTask?.cancel()

        let query = openQuicklyQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            openQuicklyFiles = []
            isShowingOpenQuicklyFiles = false
            return
        }

        let directoryURL = fileURL
        searchTask = Task { [weak self] in
            let files = await Task.detached(priority: .userInitiated) {
                Self.matchingFiles(
                    in: directoryURL,
                    query: query
                )
            }.value

            guard !Task.isCancelled else { return }

            guard self?.openQuicklyQuery.trimmingCharacters(in: .whitespacesAndNewlines) == query else {
                return
            }

            self?.openQuicklyFiles = files
            self?.isShowingOpenQuicklyFiles = !files.isEmpty
        }
    }

    /// Finds regular files matching the query.
    ///
    /// - Parameter directoryURL: The directory to search.
    /// - Parameter query: The lowercased query string.
    ///
    /// - Returns: Matching file items.
    nonisolated private static func matchingFiles(
        in directoryURL: URL,
        query: String
    ) -> [FileSystemClient.FileItem] {
        let lowercasedQuery = query.lowercased()
        let resourceKeys: [URLResourceKey] = [.isRegularFileKey]
        let enumerator = FileManager.default.enumerator(
            at: directoryURL,
            includingPropertiesForKeys: resourceKeys,
            options: [
                .skipsHiddenFiles,
                .skipsPackageDescendants
            ]
        )

        guard let filePaths = enumerator?.allObjects as? [URL] else {
            return []
        }

        return filePaths.compactMap { url in
            guard url.lastPathComponent.lowercased().contains(lowercasedQuery) else {
                return nil
            }

            do {
                let values = try url.resourceValues(
                    forKeys: [
                        .isRegularFileKey
                    ]
                )

                guard values.isRegularFile == true else {
                    return nil
                }

                return FileSystemClient.FileItem(url: url, children: nil)
            } catch {
                return nil
            }
        }
    }

    deinit {
        searchTask?.cancel()
    }
}
