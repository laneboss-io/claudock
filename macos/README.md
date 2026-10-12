# Optional macOS extension

The menu bar app lives here and depends on the repository root's `UsageCore`
library through a relative Swift package dependency. The `claudock` CLI builds
and installs from the root without this extension.

Build the app executable with `xcrun swift build --package-path macos` from the
repository root. To package it, run `./scripts/build-app.sh dist/development`.
The bundle retains `Contents/MacOS/ClaudockApp` and `Contents/MacOS/claudock`
for existing callers. Choose a fresh output directory for each bundle build.

The WidgetKit widget will land in this directory in phase 2.

See the [development guide](../CONTRIBUTING.md) and
[release checklist](../docs/RELEASING.md).
