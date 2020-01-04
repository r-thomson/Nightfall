//
//  PreferencesPopover.swift
//  Nightfall
//
//  Copyright © 2019 Ryan Thomson. All rights reserved.
//

import Cocoa
import SwiftUI

final class PreferencesPopover: NSPopover {
	static let shared = PreferencesPopover()
	
	override init() {
		super.init()
		
		self.behavior = .transient
		self.contentViewController = NSHostingController(rootView: PreferencesView())
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func show(statusButton: NSStatusBarButton) {
		show(relativeTo: statusButton.bounds, of: statusButton, preferredEdge: .minY)
	}
}
