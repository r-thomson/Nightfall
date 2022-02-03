import Cocoa
import Combine
import CoreLocation
import ServiceManagement
import os.log

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
	let statusItemController = NightfallStatusItemController()
	
	private let log: OSLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "app_delegate")
	
	// Used to return focus to the last application used
	var lastActiveApp: NSRunningApplication?
	var shouldReturnFocus = false
	
	var didDeactivateAppSubscription: Cancellable?
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Register user defaults
		UserDefaults.standard.register(defaults: [
			UserDefaults.Keys.useTransition: true,
			UserDefaults.Keys.startAtLogin: false,
			UserDefaults.Keys.checkForUpdates: true,
			UserDefaults.Keys.autoTransition: false
		])
		
		// Register the services provider
		NSApp.servicesProvider = ServicesProvider()
		
		// Begin checking for updates periodically
		AppUpdateChecker.shared.startBackgroundChecking()
		
		// Begins observing changes to the "StartAtLogin" default. The observer
		// function then reads the default to set/unset the app as a login item.
		// Because .initial is specified, it will also be set at app startup.
		UserDefaults.standard.addObserver(self,
										  forKeyPath: UserDefaults.Keys.startAtLogin,
										  options: [.initial, .new],
										  context: nil)
		
		// Watch for the user to enable/disable auto transitions, passing in the
		// current value at start up
		UserDefaults.standard.addObserver(self,
										  forKeyPath: UserDefaults.Keys.autoTransition,
										  options: [.initial, .new],
										  context: nil)
		
		// Used to track the last active application
		self.didDeactivateAppSubscription = NSWorkspace.shared.notificationCenter
			.publisher(for: NSWorkspace.didDeactivateApplicationNotification, object: nil)
			.sink { notification in
				self.lastActiveApp = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication
			}
	}
	
	func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
		// If the user has hidden the menu bar icon, they can show it again by re-opening the app
		self.statusItemController.statusItem.isVisible = true
		
		return true
	}
	
	func applicationDidBecomeActive(_ notification: Notification) {
		// Return focus to the last active application if the shouldReturnFocus flag is set
		// This is used when the app's service is called
		if shouldReturnFocus, let lastActiveApp = lastActiveApp {
			lastActiveApp.activate()
		}
		
		shouldReturnFocus = false
		lastActiveApp = nil
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?,
							   change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		
		if object as? UserDefaults === UserDefaults.standard {
			
			// watch start at login
			if keyPath == UserDefaults.Keys.startAtLogin {
				if let new = change?[.newKey] as? Bool {
					SMLoginItemSetEnabled("net.ryanthomson.NightfallLauncher" as CFString, new)
				}
			}
			
			// watch auto transition
			if keyPath == UserDefaults.Keys.autoTransition {
				os_log("detected change on autoTransition")
				if let new = change?[.newKey] as? Bool {
					os_log("autoTransition set to %{public}@", log: log, new ? "true" : "false")
					if new {
						os_log("asked for permission from pref change")
						LocationUtility.shared.requestAuthorization()
						TransitionScheduler.shared.activate()
					} else {
						TransitionScheduler.shared.deactivate()
					}
				}
			}
		}
	}
		
	deinit {
		UserDefaults.standard.removeObserver(self, forKeyPath: UserDefaults.Keys.startAtLogin)
		UserDefaults.standard.removeObserver(self, forKeyPath: UserDefaults.Keys.autoTransition)
	}
}
