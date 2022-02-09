import ArgumentParser

struct ContactsCLI: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "contactscli",
        subcommands: [list.self, save.self, delete.self]
    )
}

ContactsCLI.main()
