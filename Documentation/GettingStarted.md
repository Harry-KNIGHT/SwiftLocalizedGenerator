# Getting started and migration

## Create a localization target

Keeping translations in a small dedicated target makes the generated API easy
to import from an app and from feature packages.

```text
Sources/AppLocalization/
├── LocalizationSupport.swift
└── Resources/
    ├── Common.xcstrings
    └── Checkout.xcstrings
```

The source file may be empty. Swift requires a source target to contain at
least one source file, while the plugin supplies the generated `L10n` sources.
It is also a convenient home for project-specific helpers:

```swift
import Foundation

extension L10n {
    public static let supportedLanguageCodes = ["en", "fr"]
}
```

Add `.process("Resources")` and the plugin to the target in `Package.swift`.
The target needs no library dependency on SwiftLocalizedGenerator because the
package contributes build tooling only.

## Organize catalogs

Catalog filenames are public namespaces, so choose stable domain names rather
than screen names that are likely to change:

- `Common.xcstrings` for deliberately shared actions and messages;
- `Authentication.xcstrings` for sign-in and identity copy;
- `Commerce.xcstrings` for purchases, subscriptions, and products.

Apple flattens dots in keys when spelling Swift symbols. For example,
`purchase.confirmation_title` normally becomes `purchaseConfirmationTitle`,
not another nested namespace. Build before relying on an assumed spelling.

## Migrate an existing generator

1. Keep the existing `.xcstrings` files and resource target.
2. Remove generated Swift files from source control.
3. Remove the previous generator executable or script from the consumer repo.
4. Add the SwiftLocalizedGenerator package dependency and build-tool plugin.
5. Remove a hand-written root `enum L10n` if one exists.
6. Convert useful members from that enum into an `extension L10n`.
7. Build every target that imports the localization module.
8. Rename call sites only if the old generator used different symbol spelling.

Because the package uses Apple's generator, format placeholders and plural
variants remain governed by the String Catalog rather than migration code.

## Multiple localization targets

The plugin generates one module-scoped `L10n` enum per target. Multiple
localization targets can therefore use it independently. A consumer should
import the module that owns the desired catalogs; avoid importing two modules
that both expose `L10n` into the same source file without qualification.

## Continuous integration

Use a macOS runner with a complete Xcode installation. `swift test` or
`swift build` automatically builds the plugin and runs generation. No separate
code-generation step and no committed output directory are required.

When adopting a new Xcode major version, run the transformer and integration
tests first. They are designed to catch changes in native `xcstringstool`
output before those changes reach application targets.
