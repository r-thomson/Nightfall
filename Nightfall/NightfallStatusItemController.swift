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
			NSMenuItem(title: "Toggle Dark Mode", action: #selector(handleToggleDarkMode(_:)), target: self),
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
			button.action = #selector(handleStatusButtonPress(_:))
			button.sendAction(on: [.leftMouseUp, .rightMouseUp])
		}
	}
	
	func showContextMenu(_ sender: AnyObject? = nil) {
		statusItem.menu = contextMenu
		
		defer {
			statusItem.menu = nil // Clear the menu property so the next click will work properly
		}
		
		statusButton?.performClick(sender)
	}
	
	// MARK: Handler functions
	
	/// Handler function called when the status bar button is clicked. Determines if the click was a
	/// left click or a right click (including control-click), and takes the apropriate action.
	@objc private func handleStatusButtonPress(_ sender: NSStatusBarButton) {
		guard let event = NSApp.currentEvent else { return }
		
		guard event.clickCount > 0 else { return }
		
		/* TODO: Handle mouse up events
		The context menu should open on mouse down, as is standard for macOS menus. However,
		this caused focus issues with windows/popups. This seems that the system was treating
		the entire action as one click, so the user needed to click a second time to end the
		click and give the window focus.
		*/
		
		let controlKey = event.modifierFlags.contains(.control)
		
		if event.type == .rightMouseUp || (controlKey && event.type == .leftMouseUp) {
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
