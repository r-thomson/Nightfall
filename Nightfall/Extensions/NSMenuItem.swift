//
//  NSMenuItem.swift
//  Nightfall
//
//  Copyright © 2019 Ryan Thomson. All rights reserved.
//

import Cocoa

extension NSMenuItem {
	convenience init(title: String, action selector: Selector?, target: AnyObject? = nil,
					 keyEquivalent charCode: String = "", modifierMask: NSEvent.ModifierFlags = [.command]) {
		self.init(title: title, action: selector, keyEquivalent: charCode)
		
		self.target = target
		self.keyEquivalentModifierMask = modifierMask
	}
}
