# Nightfall

Nightfall lets you manage macOS's dark mode from the menu bar. Left click the icon to toggle dark mode; right click to reveal additional options.

https://user-images.githubusercontent.com/29545379/150662417-90e6a4f8-7ad9-436a-8ee9-0b11882e0d4a.mp4

## Installation

_Nightfall requires macOS Catalina or later_

### Direct Download

Nightfall can be downloaded directly from [**the releases page**](https://github.com/r-thomson/Nightfall/releases).

### Homebrew

Nightfall is available for download on [Homebrew Cask](https://formulae.brew.sh/cask/nightfall).

```sh
brew install --cask nightfall
```
## Usage

**Left click** Nightfall’s icon in the menu bar to toggle dark mode.  
**Right click** the icon to show the options menu.

### Setting a Keyboard Shortcut

Nightfall allows you to toggle dark mode from anywhere with a configurable keyboard shortcut. By default, this will be set to <kbd>^⌥⌘T</kbd>. You can change this in Nightfall's settings.

### Using Animated Transitions

If “Animated transition“ is enabled in preferences, Nightfall will smooth over the transition between light and dark modes with a short animation. Because of how this feature works (source code [here](Nightfall/ToggleDarkMode.swift)), **you’ll need to grant Nightfall [screen recording permissions](https://support.apple.com/guide/mac-help/control-access-to-screen-recording-on-mac-mchld6aa7d23/mac)**.

### Hiding Nightfall

If you’d like to hide Nightfall from your menu bar without quitting the app, you can do so by holding the Command key and dragging the icon out of the menu bar. To reveal Nightfall again, re-open the app while it’s still running.

### Updating Nightfall

If “Check for new versions” is enabled in preferences, Nightfall will look for updates a few times per day. When an update is available, you’ll see “Update…” in the options menu. Nightfall won’t update itself— you’ll need to download the new version manually.
