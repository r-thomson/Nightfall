//
//  AppDelegate.swift
//  NightfallLauncher
//
//  Copyright © 2020 Ryan Thomson. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		defer {
			NSApp.terminate(self)
		}
		
		let bundleID = "com.ryanthomson.Nightfall"
		
		// Check to see if the application is already running
		guard NSRunningApplication.runningApplications(withBundleIdentifier: bundleID).isEmpty
			else { return }
		
		NSWorkspace.shared.launchApplication(
			withBundleIdentifier: bundleID,
			options: .withoutActivation,
			additionalEventParamDescriptor: nil,
			launchIdentifier: nil
		)
	}
}
