//
//  CommandPaletteState.swift
//  Aurora Editor
//
//  Created by TAY KAI QUAN on 2/9/22.
//  Copyright © 2023 Aurora Company. All rights reserved.
//

import Combine
import Foundation
import OSLog

/// The state of the command palette.
@MainActor
public final class CommandPaletteState: ObservableObject {
    /// The query of the command palette.
    @Published
    var commandQuery: String = ""

    /// The commands that match the query.
    @Published
    var commands: [Command] = []

    /// The possible commands that can be executed.
    @Published
    var possibleCommands: [Command] = []

    /// A boolean value indicating whether the command palette is showing.
    @Published
    var isShowingCommands: Bool = false

    /// Logger
    let logger = Logger(subsystem: "com.auroraeditor", category: "Command Palette State")

    /// Creates a new instance of the command palette state.
    init(possibleCommands: [Command] = []) {
        self.possibleCommands = possibleCommands
    }

    /// Fetches the commands that match the query.
    func fetchCommands() {
        let query = commandQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else {
            self.logger.info("Query is empty")
            commands = []
            isShowingCommands = false
            return
        }

        let lowercasedQuery = query.lowercased()
        commands = possibleCommands
            .filter { $0.name.lowercased().contains(lowercasedQuery) }
            .sorted { $0.name.count < $1.name.count }
        isShowingCommands = !commands.isEmpty
    }

    /// Adds a command to the possible commands.
    /// 
    /// - Parameter command: The command to add.
    func addCommand(command: Command) {
        possibleCommands.append(command)
    }

    /// Adds commands to the possible commands.
    /// 
    /// - Parameter commands: The commands to add.
    func addCommands(commands: [Command]) {
        possibleCommands.append(contentsOf: commands)
    }
}
