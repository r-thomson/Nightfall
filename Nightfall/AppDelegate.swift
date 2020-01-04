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
			"UseFade" : true,
			"FadeDelay" : 0.6,
			"FadeDuration" : 0.6
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
	
	@objc func toggleDarkMode() {
		if UserDefaults.standard.bool(forKey: "UseFade") {
			showFadeOverlay()
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
