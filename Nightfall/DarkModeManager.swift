//
//  DarkModeManager.swift
//  Nightfall
//
//  Created by Ryan Thomson on 11/14/18.
//  Copyright © 2018 Ryan Thomson. All rights reserved.
//

import Foundation

func toggleDarkMode() {
	guard let scriptURL = Bundle.main.url(forResource: "ToggleDark", withExtension: "scpt") else { return }
	let script = NSAppleScript(contentsOf: scriptURL, error: nil)
	var error: NSDictionary?
	script?.executeAndReturnError(&error)
	if (error != nil) { print(String(describing: error!)) }
}
