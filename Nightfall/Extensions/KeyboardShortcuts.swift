import KeyboardShortcuts

extension KeyboardShortcuts.Name {
	static let toggleDarkMode = Self(
		"ToggleDarkMode",
		default: .init(.t, modifiers: [.control, .option, .command])
	)
}
