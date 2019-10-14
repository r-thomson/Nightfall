//
//  AppDelegate.swift
//  Nightfall
//
//  Created by Ryan Thomson on 11/13/18.
//  Copyright © 2018 Ryan Thomson. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	let menubarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
	let menubarContextMenu = NSMenu()
	
	let preferencesPopover = NSPopover()
	
	lazy var aboutWindow: NSWindowController? = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "aboutWindowController") as? NSWindowController
	
	// Used to return focus to the last application used
	var lastActiveApp: NSRunningApplication?
	var shouldReturnFocus = false
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		
		NSApp.servicesProvider = self
		
		// Register user defaults
		UserDefaults.standard.register(defaults: [
			"UseFade" : true,
			"FadeDelay" : 0.6,
			"FadeDuration" : 0.6
			])
		
		// Make the context menu
		menubarContextMenu.addItem(withTitle: "Toggle Dark Mode", action: #selector(handleTogglePress), keyEquivalent: "")
		menubarContextMenu.addItem(withTitle: "Preferences...", action: #selector(handlePreferencesPress), keyEquivalent: ",")
		menubarContextMenu.addItem(NSMenuItem.separator())
		menubarContextMenu.addItem(withTitle: "About Nightfall", action: #selector(handleAboutPress), keyEquivalent: "")
		menubarContextMenu.addItem(withTitle: "Quit Nightfall", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
		
		// Configure the menubar button
		if let menubarButton = menubarItem.button {
			menubarButton.image = NSImage(named: "MenubarIcon")
			menubarButton.toolTip = "Click to toggle dark mode\nRight click for more options"
			menubarButton.sendAction(on: [.leftMouseUp, .rightMouseUp])
			menubarButton.action = #selector(handleMenubarPress)
		}
		
		// Configure the preferences popover
		preferencesPopover.behavior = .transient
		preferencesPopover.contentViewController = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "preferencesViewController") as? PreferencesViewController
		
		// Used to track the last active application
		NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(applicationDidDeactivate), name: NSWorkspace.didDeactivateApplicationNotification, object: nil)
	}
	
	/// Handler function for whenever the menu bar button is clicked on
	@objc func handleMenubarPress(sender: NSStatusBarButton) {
		guard let event = NSApp.currentEvent else { return }
		
		if event.type == .rightMouseUp || event.modifierFlags.contains(.control) {
			// Handle right click/control click
			menubarItem.menu = menubarContextMenu
			menubarItem.button?.performClick(sender)
			menubarItem.menu = nil // Clear the menu property so the next click will work properly
			
		} else if event.type == .leftMouseUp {
			// Handle left click
			handleTogglePress()
			
		}
	}
	
	// MARK: - Context menu item handlers
	
	@objc func handleTogglePress() {
		if UserDefaults.standard.bool(forKey: "UseFade") {
			showFadeOverlay()
		}
		
		do {
			try toggleDarkMode()
		} catch {
			let alert = NSAlert()
			
			switch error as? ToggleDarkModeError {
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
	
	@objc func handlePreferencesPress() {
		if !preferencesPopover.isShown {
			if let button = menubarItem.button {
				NSApplication.shared.activate(ignoringOtherApps: true)
				preferencesPopover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
			}
		}
	}
	
	@objc func handleAboutPress() {
		aboutWindow?.showWindow(self)
		aboutWindow?.window?.makeKeyAndOrderFront(self)
		NSApp.activate(ignoringOtherApps: true)
	}
	
	/// Handler function for the "Toggle Dark Mode" global service
	@objc func toggleDarkService(_ pboard: NSPasteboard, userData: String, error: NSErrorPointer) {
		shouldReturnFocus = true
		handleTogglePress()
	}
	
	@objc func applicationDidDeactivate(_ notification: NSNotification) {
		lastActiveApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
	}
	
	func applicationDidBecomeActive(_ notification: Notification) {
		if let lastActiveApp = lastActiveApp, shouldReturnFocus {
			lastActiveApp.activate()
		}
		
		shouldReturnFocus = false
		lastActiveApp = nil
	}
	
}
