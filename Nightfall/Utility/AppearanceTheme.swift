//
//  AppearanceTheme.swift
//  Nightfall
//
//  Copyright © 2022 Ryan Thomson. All rights reserved.
//

/// Returns the current system appearance using the private SkyLight framework
func getAppearanceTheme() -> AppearanceTheme {
	return SLSGetAppearanceThemeLegacy() ? .dark : .light
}

/// Sets the system appearance using the private SkyLight framework
func setAppearanceTheme(to theme: AppearanceTheme, notify: Bool = false) {
	// Not sure what the second argument does
	SLSSetAppearanceThemeNotifying(theme == .dark, notify)
}

enum AppearanceTheme {
	case light // false
	case dark // true
}

extension AppearanceTheme {
	static prefix func !(appearanceTheme: AppearanceTheme) -> AppearanceTheme {
		return appearanceTheme == .light ? .dark : .light
	}
}
