import Foundation

public enum LocalizationSymbolTransformationError:
    Error,
    CustomStringConvertible,
    Equatable {
    case missingResourceExtension(table: String)
    case missingTableNamespace(table: String)
    case missingSymbols(table: String)

    public var description: String {
        switch self {
        case let .missingResourceExtension(table):
            "xcstringstool output for \(table) has no resource extension"

        case let .missingTableNamespace(table):
            "xcstringstool output for \(table) has no table namespace"

        case let .missingSymbols(table):
            "xcstringstool output for \(table) has no generated symbols"
        }
    }
}

/// Publishes `xcstringstool`'s package-aware symbols under a stable public
/// namespace. The transformation recognizes a deliberately small surface so
/// an upstream format change fails the build instead of silently publishing an
/// incorrect API.
public struct LocalizationSymbolTransformer {
    public init() {}

    public func transform(
        _ source: String,
        table: String,
        namespace: String
    ) throws -> String {
        let resourceExtension =
            "nonisolated extension LocalizedStringResource {"
        let namespaceExtension = "nonisolated extension \(namespace) {"
        let tableNamespace = "    enum \(table) {"
        let publicTableNamespace = "    public enum \(table) {"

        var foundResourceExtension = false
        var foundTableNamespace = false
        var symbolCount = 0

        let transformedLines = source
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { rawLine -> String in
                let line = String(rawLine)

                if line == resourceExtension {
                    foundResourceExtension = true
                    return namespaceExtension
                }

                if line == tableNamespace {
                    foundTableNamespace = true
                    return publicTableNamespace
                }

                if line.hasPrefix("        static var ")
                    || line.hasPrefix("        static let ")
                    || line.hasPrefix("        static func ") {
                    symbolCount += 1
                    return line.replacingOccurrences(
                        of: "        static ",
                        with: "        public static ",
                        options: [.anchored]
                    )
                }

                return line
            }

        guard foundResourceExtension else {
            throw LocalizationSymbolTransformationError
                .missingResourceExtension(table: table)
        }
        guard foundTableNamespace else {
            throw LocalizationSymbolTransformationError
                .missingTableNamespace(table: table)
        }
        guard symbolCount > 0 else {
            throw LocalizationSymbolTransformationError
                .missingSymbols(table: table)
        }

        return transformedLines.joined(separator: "\n")
    }
}
