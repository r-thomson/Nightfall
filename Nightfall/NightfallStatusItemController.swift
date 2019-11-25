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
			NSMenuItem(title: "Toggle Dark Mode", action: #selector(AppDelegate.toggleDarkMode), keyEquivalent: ""),
			NSMenuItem(title: "Preferences...", action: #selector(AppDelegate.openPreferencesPopup), keyEquivalent: ","),
			NSMenuItem.separator(),
			NSMenuItem(title: "About Nightfall", action: #selector(AppDelegate.openAboutWindow), keyEquivalent: ""),
			NSMenuItem(title: "Quit Nightfall", action: #selector(NSApp.terminate(_:)), keyEquivalent: "q"),
		]
		
		// Configure the status item button
		if let button = statusButton {
			button.image = NSImage(named: "MenubarIcon")
			button.toolTip = "Click to toggle dark mode\nRight click for more options"
			button.target = self
			button.action = #selector(handleStatusButtonPress)
			button.sendAction(on: [.leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp])
		}
	}
	
	func showContextMenu(_ sender: Any? = nil) {
		statusItem.menu = contextMenu
		statusButton?.performClick(sender)
		statusItem.menu = nil // Clear the menu property so the next click will work properly
	}
	
	// MARK: Handler functions
	
	/// Handler function called when the status bar button is clicked. Determines if the click was a
	/// left click or a right click (including control-click), and takes the apropriate action.
	@objc private func handleStatusButtonPress(_ sender: NSStatusBarButton) {
		guard let event = NSApp.currentEvent else { return }
		
		// Prevents odd behavior when starting a click while the cursor is moving quickly
		guard event.clickCount > 0 else { return }
		
		let controlKey = event.modifierFlags.contains(.control)
		let leftClick = event.type == .leftMouseDown || event.type == .leftMouseUp
		let rightClick = event.type == .rightMouseDown || event.type == .rightMouseUp
		
		if rightClick || (controlKey && leftClick) {
			showContextMenu(sender)
		} else if event.type == .leftMouseUp { // Not on mouse down
			(NSApp.delegate as! AppDelegate).toggleDarkMode()
		}
	}
}
