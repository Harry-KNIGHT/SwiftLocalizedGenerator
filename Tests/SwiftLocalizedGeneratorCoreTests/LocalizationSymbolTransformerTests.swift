import Testing
@testable import SwiftLocalizedGeneratorCore

@Test("Generated symbols are published under the requested namespace")
func generatedSymbolsArePublishedUnderRequestedNamespace() throws {
    let source = """
    import Foundation

    nonisolated extension LocalizedStringResource {
        /// Namespace for strings in file “App.xcstrings”.
        enum App {
            static var title: LocalizedStringResource {
                LocalizedStringResource("title", table: "App")
            }

            static func itemCount(_ arg1: Int) -> LocalizedStringResource {
                LocalizedStringResource(
                    "item_count",
                    defaultValue: "\\(arg1, specifier: \"%lld\")",
                    table: "App"
                )
            }
        }
    }
    """

    let output = try LocalizationSymbolTransformer().transform(
        source,
        table: "App",
        namespace: "L10n"
    )

    #expect(output.contains("nonisolated extension L10n {"))
    #expect(output.contains("    public enum App {"))
    #expect(
        output.contains(
            "        public static var title: LocalizedStringResource"
        )
    )
    #expect(
        output.contains(
            "        public static func itemCount(_ arg1: Int)"
        )
    )
    #expect(output.contains("defaultValue: \"\\(arg1, specifier:"))
    #expect(!output.contains("extension LocalizedStringResource"))
}

@Test("Keyword symbols remain escaped")
func keywordSymbolsRemainEscaped() throws {
    let source = """
    nonisolated extension LocalizedStringResource {
        enum Common {
            static var `continue`: LocalizedStringResource {
                LocalizedStringResource("continue", table: "Common")
            }
        }
    }
    """

    let output = try LocalizationSymbolTransformer().transform(
        source,
        table: "Common",
        namespace: "Strings"
    )

    #expect(output.contains("nonisolated extension Strings {"))
    #expect(output.contains("public static var `continue`"))
}

@Test("An upstream xcstringstool format change fails explicitly")
func upstreamFormatChangesFailExplicitly() {
    let transformer = LocalizationSymbolTransformer()

    #expect(throws: LocalizationSymbolTransformationError.self) {
        try transformer.transform(
            "enum Common {}",
            table: "Common",
            namespace: "L10n"
        )
    }
    #expect(throws: LocalizationSymbolTransformationError.self) {
        try transformer.transform(
            "nonisolated extension LocalizedStringResource {}",
            table: "Common",
            namespace: "L10n"
        )
    }
    #expect(throws: LocalizationSymbolTransformationError.self) {
        try transformer.transform(
            """
            nonisolated extension LocalizedStringResource {
                enum Common {}
            }
            """,
            table: "Common",
            namespace: "L10n"
        )
    }
}
