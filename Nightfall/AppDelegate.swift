//
//  AppDelegate.swift
//  Nightfall
//
//  Copyright © 2019 Ryan Thomson. All rights reserved.
//

import Cocoa
import ServiceManagement

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
			UserDefaults.Keys.fadeDuration: 0.6,
			UserDefaults.Keys.startAtLogin: false
		])
		
		// Register the services provider
		NSApp.servicesProvider = ServicesProvider()
		
		// Check for updates at startup and begin checking periodically
		AppUpdateChecker.shared.checkForUpdate()
		AppUpdateChecker.shared.startBackgroundChecking()
		
		// Begins observing changes to the "StartAtLogin" default. The observer
		// function then reads the default to set/unset the app as a login item.
		// Because .initial is specified, it will also be set at app startup.
		UserDefaults.standard.addObserver(self,
										  forKeyPath: UserDefaults.Keys.startAtLogin,
										  options: [.initial, .new],
										  context: nil)
		
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
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?,
		change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		
		if object as? UserDefaults === UserDefaults.standard &&
			keyPath == UserDefaults.Keys.startAtLogin {
			
			if let new = change?[.newKey] as? Bool {
				SMLoginItemSetEnabled("com.ryanthomson.NightfallLauncher" as CFString, new)
			}
		}
	}
	
	deinit {
		UserDefaults.standard.removeObserver(self, forKeyPath: UserDefaults.Keys.startAtLogin)
	}
}
