//
//  ServicesProvider.swift
//  Nightfall
//
//  Copyright © 2019 Ryan Thomson. All rights reserved.
//

import Cocoa

/// Container object for all services provided by this app.
final class ServicesProvider {
	/// Service handler for the "Toggle Dark Mode" service
	@objc func toggleDarkMode(_: Any, _: Any) {
		Nightfall.toggleDarkMode()
		(NSApp.delegate as! AppDelegate).shouldReturnFocus = true
	}
}
