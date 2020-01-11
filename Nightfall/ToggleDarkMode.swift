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
	if PermissionUtil.systemEventsPermission(canPrompt: true) != .permitted {
		let alert = NSAlert()
		alert.messageText = "System Events are not enabled for Nightfall."
		alert.informativeText = "Nightfall needs access to System Events to enable and disable dark mode. Enable \"Automation\" for Nightfall in System Preferences to use Nightfall."
		alert.addButton(withTitle: "OK")
		alert.addButton(withTitle: "Open System Preferences")
		
		if alert.runModal() == .alertSecondButtonReturn {
			// Opens the Automation section in System Preferences
			if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") {
				NSWorkspace.shared.open(url)
			}
		}
		
		return
	}
	
	let defaults = UserDefaults.standard
	
	if defaults.useFade {
		showFadeOverlay(duration: defaults.fadeDuration, after: defaults.fadeDelay)
	}
	
	do {
		try setSystemAppearance(to: .toggle)
	} catch {
		let alert = NSAlert()
		if let error = error as? AppleScriptError {
			alert.messageText = "An AppleScript error ocurred."
			if let errorNumber = error.errorNumber {
				alert.informativeText += "Error \(errorNumber)\n"
			}
			if let errorMessage = error.errorMessage {
				alert.informativeText += "\"\(errorMessage)\""
			}
		}
		alert.runModal()
	}
}
