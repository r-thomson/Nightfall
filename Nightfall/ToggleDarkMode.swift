//
//  ToggleDarkMode.swift
//  Nightfall
//
//  Copyright © 2020 Ryan Thomson. All rights reserved.
//

import Cocoa

/// Switches between light mode and dark mode.
///
/// This function includes behavior not in `setSystemAppearance(to:)`, such as displaying the fade
/// animation and displaying errors in alerts.
func toggleDarkMode() {
	let defaults = UserDefaults.standard
	
	if defaults.useFade {
		showFadeOverlay(duration: defaults.fadeDuration, after: defaults.fadeDelay)
	}
	
	do {
		try setSystemAppearance(to: .toggle)
	} catch {
		let alert = NSAlert()
		switch error as? SetSystemAppearanceError {
		case .insufficientPermissions:
			alert.messageText = "System Events are not enabled for Nightfall."
			alert.informativeText = "Nightfall needs access to System Events to enable and disable dark mode. Enable \"Automation\" for Nightfall in System Preferences to use Nightfall."
		
		case .appleScriptError(let dictionary):
			alert.messageText = "An unknown AppleScript error ocurred."
			if let errorNumber = dictionary?["NSAppleScriptErrorNumber"] as? Int {
				alert.informativeText += "Error \(errorNumber)\n"
			}
			if let errorMessage = dictionary?["NSAppleScriptErrorMessage"] as? String {
				alert.informativeText += "\"\(errorMessage)\""
			}
			
		default:
			alert.messageText = "An unknown error ocurred"
		}
		alert.runModal()
	}
}
