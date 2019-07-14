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
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		
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
	}
	
	/// Handler function for whenever the menu bar button is clicked on
	@objc func handleMenubarPress(sender: NSStatusBarButton) {
		guard let event = NSApp.currentEvent else { return }
		
		if event.type == .leftMouseUp {
			handleTogglePress()
		} else if event.type == .rightMouseUp {
			menubarItem.menu = menubarContextMenu
			menubarItem.button?.performClick(sender)
			menubarItem.menu = nil // Clear the menu property so the next click will work properly
		}
	}
	
	// MARK: - Context menu item handlers
	
	@objc func handleTogglePress() {
		if UserDefaults.standard.bool(forKey: "UseFade") {
			showFadeOverlay()
		}
		
		toggleDarkMode()
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
	
}
