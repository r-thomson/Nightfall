import Foundation

/// Provides a bindable interface for `UserDefaults` that responds to updates. Can be used with the
/// `@ObservedObject` property wrapper. `<T>` is the default value's type and must be explicitly declared.
///
/// - Warning:
/// Defaults values should be registered (`UserDefaults.register`) before this object is used.
final class ObservableUserDefault<T>: NSObject, ObservableObject {
	let defaults: UserDefaults
	let key: String
	
	/// The current value in the user's defaults database for this instance's `key`.
	///
	/// - Warning:
	/// Accessing `value` will forcibly typecast to `<T>`. If there is no defaults value for `key`, or that value cannot
	/// be typecast, a runtime error will occur.
	var value: T {
		get {
			defaults.object(forKey: key) as! T
		}
		set {
			defaults.set(newValue, forKey: key)
		}
	}
	
	/// - Parameter key: A key in the user's defaults database. This key should have a non-nil value of type `T`.
	/// - Parameter defaults: The `UserDefaults` instance to use. Defaults to `UserDefaults.standard`.
	init(_ key: String, defaults: UserDefaults = UserDefaults.standard) {
		self.defaults = defaults
		self.key = key
		super.init()
		
		// Register for notifications for changes to this value
		defaults.addObserver(self, forKeyPath: key, options: [], context: nil)
	}
	
	// Respond to changes of the UserDefault's value to update any subscribers
	override func observeValue(forKeyPath keyPath: String?, of object: Any?,
							   change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
		if object as? UserDefaults === defaults && keyPath == key {
			self.objectWillChange.send()
		}
	}
	
	deinit {
		// Remove the observer added in init
		// This prevents a crash when this object is deallocated
		defaults.removeObserver(self, forKeyPath: key)
	}
}
