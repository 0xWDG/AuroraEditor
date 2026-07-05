//
//  GitIgnore.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/08/13.
//  Copyright © 2023 Aurora Company. All rights reserved.
//
//  This source code is restricted for Aurora Editor usage only.
//

import Foundation

/// GIT ignore
public struct GitIgnore {

    /// Read the contents of the repository .gitignore.
    ///
    /// If there's no .gitignore file in the repository root this returns nil.
    /// 
    /// - Parameter directoryURL: The project url
    /// 
    /// - Returns: The contents of the .gitignore file.
    /// 
    /// - Throws: Error
    func readGitIgnoreAtRoot(directoryURL: URL) throws -> String? {
        let gitIgnoreURL = directoryURL.appendingPathComponent(".gitignore")

        guard FileManager.default.fileExists(atPath: gitIgnoreURL.path) else {
            return nil
        }

        return try String(contentsOf: gitIgnoreURL, encoding: .utf8)
    }

    /// Persist the given content to the repository root .gitignore.
    ///
    /// If the repository root doesn't contain a .gitignore file one
    /// will be created, otherwise the current file will be overwritten.
    /// 
    /// - Parameter directoryURL: The project url
    /// - Parameter text: The text to save
    /// 
    /// - Throws: Error
    func saveGitIgnore(directoryURL: URL,
                       text: String) throws {
        if text.isEmpty {
            return
        }

        let fileContents = try formatGitIgnoreContents(text: text,
                                                       directoryURL: directoryURL)
        let gitIgnoreURL = directoryURL.appendingPathComponent(".gitignore")
        try fileContents.write(to: gitIgnoreURL, atomically: true, encoding: .utf8)
    }

    /// Add the given pattern or patterns to the root gitignore file
    /// 
    /// - Parameter directoryURL: The project url
    /// - Parameter patterns: The patterns to add
    /// 
    /// - Throws: Error
    func appendIgnoreRule(directoryURL: URL, patterns: [String]) throws {
        guard !patterns.isEmpty else {
            return
        }

        let text = try readGitIgnoreAtRoot(directoryURL: directoryURL) ?? ""
        let currentContents = try formatGitIgnoreContents(text: text,
                                                          directoryURL: directoryURL)

        let newPatternText = patterns.joined(separator: "\n")
        let newText = try formatGitIgnoreContents(text: "\(currentContents)\(newPatternText)",
                                                  directoryURL: directoryURL)

        try saveGitIgnore(directoryURL: directoryURL, text: newText)
    }

    /// Convenience method to add the given file path(s) to the repository's gitignore.
    ///
    /// The file path will be escaped before adding.
    /// 
    /// - Parameter directoryURL: The project url
    /// - Parameter filePath: The file path to add
    /// 
    /// - Throws: Error
    func appendIgnoreFile(directoryURL: URL,
                          filePath: [String]) throws {
        let escapedFilePaths = filePath.map {
            escapeGitSpecialCharacters(pattern: $0)
        }

        try appendIgnoreRule(directoryURL: directoryURL, patterns: escapedFilePaths)
    }

    /// Escapes a string from special characters used in a gitignore file
    /// 
    /// - Parameter pattern: The pattern to escape
    /// 
    /// - Returns: The escaped pattern
    func escapeGitSpecialCharacters(pattern: String) -> String {
        let specialCharacters = Set("/[]!*#?")

        return pattern.reduce(into: "") { result, character in
            if specialCharacters.contains(character) {
                result.append("\\")
            }

            result.append(character)
        }
    }

    /// Format the gitignore text based on the current config settings.
    ///
    /// Normalizes line endings to LF and keeps a trailing newline.
    ///
    /// - Parameter text: The text to format
    /// - Parameter directoryURL: The project url
    /// 
    /// - Returns: The formatted text
    /// 
    /// - Throws: Error
    @discardableResult
    func formatGitIgnoreContents(text: String,
                                 directoryURL: URL) throws -> String {
        let normalizedLines = text
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)

        let contents = normalizedLines.joined(separator: "\n")
        return contents.hasSuffix("\n") ? contents : "\(contents)\n"
    }
}
