//
//  NightfallStatusItemController.swift
//  Nightfall
//
//  Copyright © 2019 Ryan Thomson. All rights reserved.
//

import Cocoa

/// Wrapper class around Nightfall's `NSStatusItem` instance.
final class NightfallStatusItemController {
	let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
	private let contextMenu = NSMenu()
	
	/// Alias for `statusItem.button`
	var statusButton: NSStatusBarButton? {
		return statusItem.button
	}
	
	init() {
		// Make the context menu
		contextMenu.items = [
			NSMenuItem(title: "Toggle Dark Mode", action: #selector(handleToggleDarkMode(_:))),
			NSMenuItem.separator(),
			NSMenuItem(title: "Preferences...", action: #selector(handleOpenPreferences(_:)), target: self, keyEquivalent: ","),
			NSMenuItem.separator(),
			NSMenuItem(title: "About Nightfall", action: #selector(handleOpenAboutWindow(_:)), target: self),
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
	
	func showContextMenu(_ sender: AnyObject? = nil) {
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
			toggleDarkMode()
		}
	}
	
	/// Handler function for when the "Toggle Dark Mode" menu item is clicked.
	@objc func handleToggleDarkMode(_ sender: NSMenuItem) {
		toggleDarkMode()
	}
	
	/// Handler function called when the "About Nightfall" menu item is clicked.
	@objc func handleOpenAboutWindow(_ sender: NSMenuItem) {
		AboutWindowController.shared.showWindow(sender)
		NSApp.activate(ignoringOtherApps: true)
	}
	
	/// Handler function called when the "Preferences..." menu item is clicked.
	@objc func handleOpenPreferences(_ sender: NSMenuItem) {
		guard let button = statusButton else { return }
		
		if !PreferencesPopover.shared.isShown {
			PreferencesPopover.shared.show(statusButton: button)
			NSApp.activate(ignoringOtherApps: true)
		}
	}
}
