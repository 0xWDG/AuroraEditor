//
//  AccountsPreferences.swift
//  Aurora Editor
//
//  Created by Nanashi Li on 2022/04/08.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Foundation

public extension AppPreferences {
    /// The global settings for text editing
    struct AccountsPreferences: Codable {
        /// An integer indicating how many spaces a `tab` will generate
        public var sourceControlAccounts: GitAccounts = .init()

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.sourceControlAccounts = try container.decodeIfPresent(
                GitAccounts.self,
                forKey: .sourceControlAccounts
            ) ?? .init()
        }
    }

    /// The global settings for text editing
    struct GitAccounts: Codable {
        /// This id will store the account name as the identifiable
        public var gitAccount: [SourceControlAccounts] = []

        public var sshKey: String = ""

        /// Default initializer
        public init() {}

        /// Explicit decoder init for setting default values when key is not present in `JSON`
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.gitAccount = try container.decodeIfPresent([SourceControlAccounts].self, forKey: .gitAccount) ?? []
            self.sshKey = try container.decodeIfPresent(String.self, forKey: .sshKey) ?? ""
        }
    }
}
