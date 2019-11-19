//
//  CGImageOverlayWindow.swift
//  Nightfall
//
//  Copyright © 2019 Ryan Thomson. All rights reserved.
//

import Cocoa

/// Displays a `CGImage` as an overlay. The overlay is non-interactive and appears above all windows.
class CGImageOverlayWindow: NSWindow {
	init(_ image: CGImage, position: NSRect) {
		super.init(contentRect: position, styleMask: .borderless, backing: .buffered, defer: false)
		self.backgroundColor = .clear
		self.collectionBehavior = [.ignoresCycle, .stationary]
		self.ignoresMouseEvents = true
		self.level = .statusBar // Place above other windows, dock, and menu bar
		
		// Display the screenshot on the overlay
		self.contentView?.wantsLayer = true
		self.contentView?.layer?.contents = image
	}
}
