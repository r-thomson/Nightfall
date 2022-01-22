//
//  ToggleDarkMode.swift
//  Nightfall
//
//  Copyright © 2020 Ryan Thomson. All rights reserved.
//

import Cocoa

/// Toggles the system between light and dark modes, using a transition animation if available.
func toggleDarkMode() {
	let defaults = UserDefaults.standard
	
	let transition: NSGlobalPreferenceTransition?
	if defaults.useTransition && PermissionUtil.checkScreenCapturePermission(canPrompt: true) {
		transition = NSGlobalPreferenceTransition.transition() as! NSGlobalPreferenceTransition?
	} else {
		transition = nil
	}
	
	// If the transition is disabled, the second argument must be true or nothing happens
	setAppearanceTheme(to: !getAppearanceTheme(), notify: transition == nil)
	
	transition?.postChangeNotification(0) {}
}
