//
//  NightfallStatusItemController.swift
//  Nightfall
//
//  Copyright © 2019 Ryan Thomson. All rights reserved.
//

import Cocoa

/// Wrapper class around Nightfall's `NSStatusItem` instance.
class NightfallStatusItemController {
	let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
	private let contextMenu = NSMenu()
	
	/// Alias for `statusItem.button`
	var statusButton: NSButton? {
		return statusItem.button
	}
	
	init() {
		// Make the context menu
		contextMenu.items = [
			NSMenuItem(title: "Toggle Dark Mode", action: #selector(AppDelegate.handleTogglePress), keyEquivalent: ""),
			NSMenuItem(title: "Preferences...", action: #selector(AppDelegate.handlePreferencesPress), keyEquivalent: ","),
			NSMenuItem.separator(),
			NSMenuItem(title: "About Nightfall", action: #selector(AppDelegate.handleAboutPress), keyEquivalent: ""),
			NSMenuItem(title: "Quit Nightfall", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"),
		]
		
		// Configure the status item button
		if let button = statusButton {
			button.image = NSImage(named: "MenubarIcon")
			button.toolTip = "Click to toggle dark mode\nRight click for more options"
			button.target = self
			button.action = #selector(handleStatusButtonPress)
			button.sendAction(on: [.leftMouseUp, .rightMouseUp])
		}
	}
	
	// MARK: Handler functions
	
	/// Handler function called when the status bar button is clicked. Determines if the click was a
	/// left click or a right click, and takes the apropriate action.
	@objc private func handleStatusButtonPress(sender: NSStatusBarButton) {
		guard let event = NSApp.currentEvent else { return }
		
		if event.type == .rightMouseUp || event.modifierFlags.contains(.control) {
			// Handle right click/control click
			statusItem.menu = contextMenu
			statusItem.button?.performClick(sender)
			statusItem.menu = nil // Clear the menu property so the next click will work properly
		} else if event.type == .leftMouseUp {
			// Handle left click
			// FIXME: Move this behavior out of AppDelegate
			NSApp.delegate!.perform(#selector(AppDelegate.handleTogglePress))
		}
	}
}
