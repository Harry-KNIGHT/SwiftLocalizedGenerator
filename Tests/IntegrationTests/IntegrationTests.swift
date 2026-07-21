import Foundation
import Testing
import FixtureLocalization

@Test("The plugin generates public static resources")
func pluginGeneratesPublicStaticResources() {
    let resource: LocalizedStringResource = L10n.App.welcomeTitle

    #if os(iOS)
    var localizedResource = resource
    localizedResource.locale = Locale(identifier: "en")
    #expect(String(localized: localizedResource) == "Welcome")
    #else
    _ = resource
    #endif
}

@Test("The plugin preserves interpolation and plural signatures")
func pluginPreservesInterpolationAndPluralSignatures() {
    let plural: (Int) -> LocalizedStringResource = L10n.App.itemCount
    let interpolation: (String) -> LocalizedStringResource =
        L10n.App.welcomeUser

    #if os(iOS)
    var englishPlural = L10n.App.itemCount(2)
    englishPlural.locale = Locale(identifier: "en")

    var frenchSingular = L10n.App.itemCount(1)
    frenchSingular.locale = Locale(identifier: "fr")

    var greeting = L10n.App.welcomeUser("Taylor")
    greeting.locale = Locale(identifier: "en")

    #expect(String(localized: englishPlural) == "2 items")
    #expect(String(localized: frenchSingular) == "1 élément")
    #expect(String(localized: greeting) == "Welcome, Taylor!")
    #else
    _ = plural(2)
    _ = interpolation("Taylor")
    #endif
}
