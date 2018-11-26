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
	
	lazy var aboutWindow: NSWindowController? = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "aboutWindowController") as? NSWindowController
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Make the context menu
		menubarContextMenu.addItem(NSMenuItem(title: "Toggle Dark Mode", action: #selector(handleTogglePress), keyEquivalent: ""))
		menubarContextMenu.addItem(NSMenuItem.separator())
		menubarContextMenu.addItem(NSMenuItem(title: "About Nightfall", action: #selector(handleAboutPress), keyEquivalent: ""))
		menubarContextMenu.addItem(NSMenuItem(title: "Quit Nightfall", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
		
		// Configure the menubar button
		let menubarButton = menubarItem.button
		menubarButton?.image = NSImage(named: "MenubarIcon")
		menubarButton?.toolTip = "Toggle Dark Mode"
		menubarButton?.sendAction(on: [.leftMouseUp, .rightMouseUp])
		menubarButton?.action = #selector(handleMenubarPress)
	}
	
	@objc func handleMenubarPress(sender: NSStatusBarButton) {
		guard let event = NSApp.currentEvent else { return }
		
		if event.type == .leftMouseUp {
			toggleDarkMode()
		} else if event.type == .rightMouseUp {
			menubarItem.menu = menubarContextMenu
			menubarItem.button?.performClick(sender)
			menubarItem.menu = nil // Clear the menu property so the next click will work properly
		}
	}
	
	@objc func handleTogglePress() {
		toggleDarkMode()
	}
	
	@objc func handleAboutPress() {
		aboutWindow?.showWindow(self)
		aboutWindow?.window?.makeKeyAndOrderFront(self)
		NSApp.activate(ignoringOtherApps: true)
	}
	
}
