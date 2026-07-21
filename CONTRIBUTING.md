# Contributing

Contributions are welcome through focused, reviewable pull requests.

## Development

Requirements are the same as the package: macOS, Xcode 26 or newer, and Swift
6.2 or newer.

```sh
git clone https://github.com/Harry-KNIGHT/SwiftLocalizedGenerator.git
cd SwiftLocalizedGenerator
swift test
```

The test suite contains:

- unit tests for the strict transformation of Apple's generated Swift source;
- an end-to-end fixture target whose `.xcstrings` file is processed by the
  plugin during the test build;
- iOS runtime assertions for static strings, interpolation, and plural forms.

## Change guidelines

- Keep the package dependency-free unless a strong use case justifies a new
  dependency.
- Preserve `xcstringstool` as the parser and native symbol generator.
- Do not commit `.build`, DerivedData, or generated Swift output.
- Add a focused test for every supported native output shape.
- Fail explicitly when an upstream output change cannot be handled safely.
- Update the README and changelog when behavior or setup changes.

Before opening a pull request, run:

```sh
swift test
git diff --check
```
