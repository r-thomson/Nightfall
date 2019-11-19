//
//  SystemAppearance.swift
//  Nightfall
//
//  Copyright © 2019 Ryan Thomson. All rights reserved.
//

import Foundation

/// Sets the system appearance. Uses AppleScript, so System Events must be enabled.
///
/// - Parameter appearance: The new system appearance.
func setSystemAppearance(to appearance: SystemAppearance) throws {
	let scriptSource = """
		tell application "System Events"
			tell appearance preferences
				set dark mode to \(appearance.rawValue)
			end tell
		end tell
		"""
	
	// This forced unwrap should be safe, as I can't find any situation where it returns nil
	let script = NSAppleScript(source: scriptSource)!
	
	var error: NSDictionary?
	script.executeAndReturnError(&error)
	
	if let error = error {
		if error["NSAppleScriptErrorNumber"] as? Int == -1743 {
			throw SetSystemAppearanceError.insufficientPermissions
		}
		throw SetSystemAppearanceError.appleScriptError(error)
	}
}

enum SystemAppearance : String {
	case light = "no"
	case dark = "yes"
	case toggle = "not dark mode"
}

enum SetSystemAppearanceError : Error {
	case appleScriptError(NSDictionary?)
	case insufficientPermissions
}
