//
//  AppDelegate.swift
//  Nightfall
//
//  Copyright © 2018 Ryan Thomson. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	let statusItemController = NightfallStatusItemController()
	
	let preferencesPopover = NSPopover()
	
	lazy var aboutWindow: NSWindowController? = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "aboutWindowController") as? NSWindowController
	
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
		
		// Configure the preferences popover
		preferencesPopover.behavior = .transient
		preferencesPopover.contentViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "preferencesViewController") as? PreferencesViewController
		
		// Used to track the last active application
		let center = NSWorkspace.shared.notificationCenter
		let name = NSWorkspace.didDeactivateApplicationNotification
		center.addObserver(forName: name, object: nil, queue: nil) { notification in
			self.lastActiveApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
		}
	}
	
	// MARK: - Context menu item handlers
	
	@objc func handleTogglePress() {
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
		if shouldReturnFocus, let lastActiveApp = lastActiveApp {
			lastActiveApp.activate()
		}
		
		shouldReturnFocus = false
		lastActiveApp = nil
	}
	
	// MARK:- Window/Panel Opening Functions
	
	/// Opens the preferences popup, making this the foreground app in the process.
	@objc func openPreferencesPopup(_ sender: Any? = nil) {
		if !preferencesPopover.isShown {
			if let button = statusItemController.statusButton {
				preferencesPopover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
				NSApp.activate(ignoringOtherApps: true)
			}
		}
	}
	
	/// Opens the application's About window, making this the foreground app in the process.
	@objc func openAboutWindow(_ sender: Any? = nil) {
		aboutWindow?.window?.makeKeyAndOrderFront(sender)
		NSApp.activate(ignoringOtherApps: true)
	}
}
