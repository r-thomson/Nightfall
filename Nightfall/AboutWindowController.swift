//
//  AboutWindowController.swift
//  Nightfall
//
//  Copyright © 2019 Ryan Thomson. All rights reserved.
//

import Cocoa
import SwiftUI

final class AboutWindowController : NSWindowController {
	
	static let shared = AboutWindowController()
	
	init() {
		let hostingVC = NSHostingController(rootView: AboutView())
		super.init(window: NSWindow(contentViewController: hostingVC))
		
		let window = self.window!
		window.styleMask = [.titled, .closable, .fullSizeContentView]
		window.title = "About Nightfall"
		window.titleVisibility = .hidden
		window.titlebarAppearsTransparent = true
		window.collectionBehavior = [.canJoinAllSpaces]
		window.animationBehavior = .alertPanel
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
