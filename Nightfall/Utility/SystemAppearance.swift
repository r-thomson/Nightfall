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
		throw AppleScriptError(error)
	}
}

enum SystemAppearance: String {
	case light = "no"
	case dark = "yes"
	case toggle = "not dark mode"
}

struct AppleScriptError : Error {
	let errorDict: NSDictionary
	let errorNumber: Int?
	let errorMessage: String?
	
	init(_ errorInfo: NSDictionary) {
		self.errorDict = errorInfo
		self.errorNumber = errorDict["NSAppleScriptErrorNumber"] as? Int
		self.errorMessage = errorDict["NSAppleScriptErrorMessage"] as? String
	}
}
