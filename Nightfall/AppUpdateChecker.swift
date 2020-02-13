//
//  AppUpdateChecker.swift
//  Nightfall
//
//  Copyright © 2020 Ryan Thomson. All rights reserved.
//

import Foundation

final class AppUpdateChecker {
	static let shared = AppUpdateChecker()
	
	/// The Semantic Version number derived from this application's bundle.
	let localVersion: SemanticVersion? = {
		guard let bundleVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
			as? String else { return nil }
		return SemanticVersion(bundleVer)
	}()
	
	private(set) var remoteVersion: SemanticVersion?
	
	private(set) var isOutdated: Bool?
	
	private static let schedulerIdentifier = Bundle.main.bundleIdentifier! + ".updatecheck"
	private let updateScheduler = NSBackgroundActivityScheduler(identifier: schedulerIdentifier)
	
	init() {
		updateScheduler.repeats = true
		//updateScheduler.interval = 60 * 60 * 16 // 16 hours in seconds
		updateScheduler.interval = 15 // temporary testing value
	}
	
	/// Checks if there is an update available by retrieving the latest release version from Nightfall's
	/// GitHub repository. Updates `remoteVersion` and `isOutdated`.
	func checkForUpdate() {
		// Only check for updates if the user has the preference enabled
		guard UserDefaults.standard.checkForUpdates else { return }
		
		GithubAPI.getLatestRelease() { (result) in
			switch result {
			case .success(let release):
				self.remoteVersion = SemanticVersion(release.version)
				
				if let remoteVersion = self.remoteVersion, let localVersion = self.localVersion {
					self.isOutdated = remoteVersion > localVersion
					
					#if DEBUG
					NSLog("Update check successful, got remote version %@", remoteVersion.description)
					#endif
				} else {
					self.isOutdated = nil
				}
			case .failure(let error):
				NSLog("Error checking for updates\n'%@'", error.localizedDescription)
			}
		}
	}
	
	/// Begins periodically checking for updates in the background.
	func startBackgroundChecking() {
		updateScheduler.schedule() { completion in
			if self.updateScheduler.shouldDefer {
				completion(.deferred)
			} else {
				self.checkForUpdate()
				completion(.finished)
			}
		}
	}
	
	/// Stops periodically checking for updates.
	func stopBackgroundChecking() {
		updateScheduler.invalidate()
	}
}
