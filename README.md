# Nightfall

A menu bar utility for quickly toggling macOS's dark mode.

![Animation showing the app in use](https://thumbs.gfycat.com/JitteryJampackedCalf-size_restricted.gif)

Left clicking the icon toggles dark mode; right clicking reveals more options.

## Installation

_Nightfall requires macOS Catalina or later_

Note: these builds are not signed; you will need to bypass Gatekeeper to run Nightfall. See [Apple Support: Open a Mac app from an unidentified developer](https://support.apple.com/guide/mac-help/open-a-mac-app-from-an-unidentified-developer-mh40616/mac).

### Homebrew

Nightfall is available on [Homebrew Cask](https://github.com/Homebrew/homebrew-cask).

```
brew install --cask nightfall
```

### Direct Download

Direct downloads can be found on the [**releases page**](https://github.com/r-thomson/Nightfall/releases).

### Note: Screen Recording Permissions

Nightfall includes an optional feature which smooths over the transition between light and dark modes. Because of how it is implemented, you will need to grant Nightfall screen recording permissions to use this feature (you can find the code for this [here](https://github.com/r-thomson/Nightfall/blob/master/Nightfall/FadeOverlay.swift)).
