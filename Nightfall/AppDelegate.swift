//
//  AppDelegate.swift
//  Nightfall
//
//  Copyright © 2019 Ryan Thomson. All rights reserved.
//

import Cocoa

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
	let statusItemController = NightfallStatusItemController()
	
	// Used to return focus to the last application used
	var lastActiveApp: NSRunningApplication?
	var shouldReturnFocus = false
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Register user defaults
		UserDefaults.standard.register(defaults: [
			UserDefaults.Keys.useFade: true,
			UserDefaults.Keys.fadeDelay: 0.6,
			UserDefaults.Keys.fadeDuration: 0.6
		])
		
		// Register the services provider
		NSApp.servicesProvider = ServicesProvider()
		
		// Used to track the last active application
		let nc = NSWorkspace.shared.notificationCenter
		let name = NSWorkspace.didDeactivateApplicationNotification
		nc.addObserver(forName: name, object: nil, queue: nil) { notification in
			self.lastActiveApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
		}
	}
	
	func applicationDidBecomeActive(_ notification: Notification) {
		// Return focus to the last active application if the shouldReturnFocus flag is set
		// This is used when the app's service is called
		if shouldReturnFocus, let lastActiveApp = lastActiveApp {
			lastActiveApp.activate()
		}
		
		shouldReturnFocus = false
		lastActiveApp = nil
	}
}
