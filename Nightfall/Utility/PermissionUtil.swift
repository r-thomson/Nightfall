//
//  PermissionUtil.swift
//  Nightfall
//
//  Copyright © 2020 Ryan Thomson. All rights reserved.
//

import Cocoa

struct PermissionUtil {
	static func systemEventsPermission(canPrompt: Bool) -> PermissionStatus {
		let bundleId = "com.apple.systemevents"
		
		// The System Events application must be running
		NSWorkspace.shared.launchApplication(withBundleIdentifier: bundleId,
			additionalEventParamDescriptor: nil, launchIdentifier: nil)
		
		let target = NSAppleEventDescriptor(bundleIdentifier: bundleId)
		let status = AEDeterminePermissionToAutomateTarget(target.aeDesc, typeWildCard, typeWildCard, canPrompt)
		
		switch status {
		case noErr:
			return .permitted
		case OSStatus(errAEEventWouldRequireUserConsent):
			return .notYetPrompted
		case OSStatus(errAEEventNotPermitted):
			return .notPermitted
		default: // includes procNotFound
			return .indeterminate
		}
	}
	
	enum PermissionStatus {
		case notPermitted
		case notYetPrompted
		case permitted
		case indeterminate
	}
}
