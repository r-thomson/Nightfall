# Nightfall

Nightfall lets you manage macOS's dark mode from the menu bar. Left click the icon to toggle dark mode; right click to reveal additional options.

https://user-images.githubusercontent.com/29545379/150662417-90e6a4f8-7ad9-436a-8ee9-0b11882e0d4a.mp4

## Installation

_Nightfall requires macOS Catalina or later_

Note: these builds are not signed; you will need to bypass Gatekeeper to run Nightfall. See [Apple Support: Open a Mac app from an unidentified developer](https://support.apple.com/guide/mac-help/open-a-mac-app-from-an-unidentified-developer-mh40616/mac).

### Homebrew

Nightfall is available on [Homebrew Cask](https://github.com/Homebrew/homebrew-cask).

```sh
brew install --cask nightfall
```

### Direct Download

Nightfall can be downloaded directly from the [**releases page**](https://github.com/r-thomson/Nightfall/releases).

### Note: Screen Recording Permissions

Nightfall includes an optional feature which smooths over the transition between light and dark modes. Because of how it is implemented, you will need to grant Nightfall screen recording permissions to use this feature (you can find the code for this [here](https://github.com/r-thomson/Nightfall/blob/master/Nightfall/ToggleDarkMode.swift)).
