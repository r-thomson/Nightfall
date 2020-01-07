//
//  FadeOverlay.swift
//  Nightfall
//
//  Copyright © 2019 Ryan Thomson. All rights reserved.
//

import Cocoa

func showFadeOverlay() {
	let defaults = UserDefaults.standard
	let fadeDelay = defaults.fadeDelay
	let fadeDuration = defaults.fadeDuration
	
	for screen in NSScreen.screens {
		let cgDisplayID = CGDirectDisplayID(screen: screen)
		guard let screenshot = CGDisplayCreateImage(cgDisplayID) else { continue }
		
		let overlay = CGImageOverlayWindow(screenshot, position: screen.frame)
		overlay.orderFront(nil)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + fadeDelay) { [overlay] in
			NSAnimationContext.runAnimationGroup({ context in
				context.duration = fadeDuration
				overlay.animator().alphaValue = 0.0
			}, completionHandler: {
				overlay.orderOut(nil)
			})
		}
	}
}
