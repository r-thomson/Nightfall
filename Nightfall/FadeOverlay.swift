//
//  FadeOverlay.swift
//  Nightfall
//
//  Copyright © 2019 Ryan Thomson. All rights reserved.
//

import Cocoa

func showFadeOverlay(duration: Double, after delay: Double) {
	// Screen capture permissions are required for the effect to work
	guard PermissionUtil.checkScreenCapturePermission(canPrompt: true) else { return }
	
	for screen in NSScreen.screens {
		let cgDisplayID = CGDirectDisplayID(screen: screen)
		guard let screenshot = CGDisplayCreateImage(cgDisplayID) else { continue }
		
		let overlay = CGImageOverlayWindow(screenshot, position: screen.frame)
		overlay.orderFront(nil)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [overlay] in
			NSAnimationContext.runAnimationGroup({ context in
				context.duration = duration
				overlay.animator().alphaValue = 0.0
			}, completionHandler: {
				overlay.orderOut(nil)
			})
		}
	}
}
