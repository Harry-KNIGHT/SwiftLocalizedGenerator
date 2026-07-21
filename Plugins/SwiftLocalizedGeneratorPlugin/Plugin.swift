import Foundation
import PackagePlugin

@main
struct SwiftLocalizedGeneratorPlugin: BuildToolPlugin {
    func createBuildCommands(
        context: PluginContext,
        target: any Target
    ) async throws -> [Command] {
        let namespace = "L10n"
        let tool = try context.tool(named: "SwiftLocalizedGenerator")
        let resourcesDirectory = target.directoryURL.appending(
            path: "Resources",
            directoryHint: .isDirectory
        )
        let outputDirectory = context.pluginWorkDirectoryURL.appending(
            path: "Generated",
            directoryHint: .isDirectory
        )

        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(
            atPath: resourcesDirectory.path,
            isDirectory: &isDirectory
        ), isDirectory.boolValue else {
            Diagnostics.error(
                "SwiftLocalizedGenerator requires a Resources directory in "
                    + "target \(target.name)"
            )
            return []
        }

        try FileManager.default.createDirectory(
            at: outputDirectory,
            withIntermediateDirectories: true
        )

        let catalogs = try FileManager.default
            .contentsOfDirectory(
                at: resourcesDirectory,
                includingPropertiesForKeys: nil
            )
            .filter { $0.pathExtension == "xcstrings" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        guard !catalogs.isEmpty else {
            Diagnostics.error(
                "SwiftLocalizedGenerator requires at least one root-level "
                    + ".xcstrings catalog in \(resourcesDirectory.path)"
            )
            return []
        }

        for catalog in catalogs {
            let table = catalog.deletingPathExtension().lastPathComponent
            guard table.range(
                of: "^[A-Z][A-Za-z0-9]*$",
                options: .regularExpression
            ) != nil else {
                Diagnostics.error(
                    "Catalog \(catalog.lastPathComponent) must use an "
                        + "UpperCamelCase filename containing only ASCII "
                        + "letters and numbers"
                )
                return []
            }
        }

        let rootOutput = outputDirectory.appending(
            path: "L10n.generated.swift"
        )
        var commands: [Command] = [
            .buildCommand(
                displayName: "Generate \(namespace) localization namespace",
                executable: tool.url,
                arguments: [
                    "--namespace", namespace,
                    "--output", rootOutput.path
                ],
                outputFiles: [rootOutput]
            )
        ]

        commands.append(contentsOf: catalogs.map { catalog in
            let table = catalog.deletingPathExtension().lastPathComponent
            let output = outputDirectory.appending(
                path: "L10n+\(table).generated.swift"
            )

            return .buildCommand(
                displayName: "Generate \(table) localization symbols",
                executable: tool.url,
                arguments: [
                    "--input", catalog.path,
                    "--namespace", namespace,
                    "--output", output.path
                ],
                inputFiles: [catalog],
                outputFiles: [output]
            )
        })

        return commands
    }
}
