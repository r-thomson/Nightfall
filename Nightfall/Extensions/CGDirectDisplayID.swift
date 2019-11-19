//
//  CGDirectDisplayID.swift
//  Nightfall
//
//  Copyright © 2019 Ryan Thomson. All rights reserved.
//

import Cocoa

extension CGDirectDisplayID {
	/// Creates a `CGDirectDisplayID` associated with the given `NSScreen`.
	init(screen: NSScreen) {
		self = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as! CGDirectDisplayID
	}
}
