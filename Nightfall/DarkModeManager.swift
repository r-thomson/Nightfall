//
//  DarkModeManager.swift
//  Nightfall
//
//  Created by Ryan Thomson on 11/14/18.
//  Copyright © 2018 Ryan Thomson. All rights reserved.
//

import Foundation

func toggleDarkMode() throws {
	var error: NSDictionary?
	
	guard let scriptURL = Bundle.main.url(forResource: "ToggleDark", withExtension: "scpt") else {
		throw ToggleDarkModeError.fileNotFound
	}
	
	guard let script = NSAppleScript(contentsOf: scriptURL, error: &error) else {
		throw ToggleDarkModeError.appleScriptError(error)
	}
	
	script.executeAndReturnError(&error)
	
	if let error = error {
		if error["NSAppleScriptErrorNumber"] as? Int == -1743 {
			throw ToggleDarkModeError.insufficientPermissions
		}
		throw ToggleDarkModeError.appleScriptError(error)
	}
	
}

enum ToggleDarkModeError : Error {
	case appleScriptError(NSDictionary?)
	case fileNotFound
	case insufficientPermissions
}
