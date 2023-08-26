import Foundation

extension UserDefaults {
	struct Keys {
		static let useTransition = "UseTransition"
		static let startAtLogin = "StartAtLogin"
		static let checkForUpdates = "CheckForUpdates"
	}

	var useTransition: Bool {
		get { self.bool(forKey: Keys.useTransition) }
		set { self.set(newValue, forKey: Keys.useTransition) }
	}

	var startAtLogin: Bool {
		get { self.bool(forKey: Keys.startAtLogin) }
		set { self.set(newValue, forKey: Keys.startAtLogin) }
	}

	var checkForUpdates: Bool {
		get { self.bool(forKey: Keys.checkForUpdates) }
		set { self.set(newValue, forKey: Keys.checkForUpdates) }
	}
}
