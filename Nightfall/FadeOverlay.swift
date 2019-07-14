//
//  TransitionWindow.swift
//  Nightfall
//
//  Created by Ryan Thomson on 7/12/19.
//  Copyright © 2019 Ryan Thomson. All rights reserved.
//

import Cocoa

func showFadeOverlay() {
	let defaults = UserDefaults.standard
	let fadeDelay = defaults.double(forKey: "FadeDelay")
	let fadeDuration = defaults.double(forKey: "FadeDuration")
	
	for screen in NSScreen.screens {
		
		// NSScreen and CGDirectDisplayID use different ID systems, and we need both
		guard let cgDisplayID = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")]
			as? CGDirectDisplayID else { continue }
		
		let screenshot = CGDisplayCreateImage(cgDisplayID)
		
		// Create a window to display as an overlay
		let overlay = NSWindow(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: true)
		overlay.level = .statusBar // Place above other windows, dock, and menu bar
		overlay.collectionBehavior = .stationary // Don't move in mission control and expose
		overlay.ignoresMouseEvents = true
		
		// Display the screenshot on the overlay
		overlay.contentView?.wantsLayer = true
		overlay.contentView?.layer?.contents = screenshot
		
		overlay.makeKeyAndOrderFront(nil)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + fadeDelay) {
			NSAnimationContext.runAnimationGroup({ (context) in
				context.duration = fadeDuration
				overlay.animator().alphaValue = 0
			}, completionHandler: {
				overlay.orderOut(nil)
			})
		}
	}
	
}
