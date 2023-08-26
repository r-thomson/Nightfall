import Cocoa
import Combine
import KeyboardShortcuts
import ServiceManagement

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
	let statusItemController = NightfallStatusItemController()

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Register user defaults
		UserDefaults.standard.register(defaults: [
			UserDefaults.Keys.useTransition: true,
			UserDefaults.Keys.startAtLogin: false,
			UserDefaults.Keys.checkForUpdates: true,
		])

		// Register global keyboard shortcut listener
		KeyboardShortcuts.onKeyDown(for: .toggleDarkMode) {
			toggleDarkMode()
		}

		// Begin checking for updates periodically
		AppUpdateChecker.shared.startBackgroundChecking()

		// Begins observing changes to the "StartAtLogin" default. The observer
		// function then reads the default to set/unset the app as a login item.
		// Because .initial is specified, it will also be set at app startup.
		UserDefaults.standard.addObserver(
			self,
			forKeyPath: UserDefaults.Keys.startAtLogin,
			options: [.initial, .new],
			context: nil
		)
	}

	func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool)
		-> Bool
	{
		// If the user has hidden the menu bar icon, they can show it again by re-opening the app
		self.statusItemController.statusItem.isVisible = true

		return true
	}

	override func observeValue(
		forKeyPath keyPath: String?, of object: Any?,
		change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?
	) {

		if object as? UserDefaults === UserDefaults.standard
			&& keyPath == UserDefaults.Keys.startAtLogin
		{

			if let new = change?[.newKey] as? Bool {
				SMLoginItemSetEnabled("net.ryanthomson.NightfallLauncher" as CFString, new)
			}
		}
	}

	deinit {
		UserDefaults.standard.removeObserver(self, forKeyPath: UserDefaults.Keys.startAtLogin)
	}
}
