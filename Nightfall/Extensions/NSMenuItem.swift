import Cocoa
import KeyboardShortcuts

extension NSMenuItem {
	convenience init(
		title: String, action selector: Selector?, target: AnyObject? = nil,
		keyEquivalent charCode: String = "", modifierMask: NSEvent.ModifierFlags = [.command]
	) {
		self.init(title: title, action: selector, keyEquivalent: charCode)

		self.target = target
		self.keyEquivalentModifierMask = modifierMask
	}

	convenience init(
		title: String, action selector: Selector?, target: AnyObject? = nil,
		shortcut: KeyboardShortcuts.Name
	) {
		self.init(title: title, action: selector)

		self.target = target
		self.setShortcut(for: shortcut)
	}
}
