import Cocoa
import SwiftUI

final class AboutWindowController: NSWindowController {
	static let shared = AboutWindowController()

	init() {
		let hostingVC = NSHostingController(rootView: AboutView())
		super.init(window: NSWindow(contentViewController: hostingVC))

		if let window = self.window {
			window.animationBehavior = .alertPanel
			window.collectionBehavior = [.canJoinAllSpaces]
			window.styleMask = [.closable, .fullSizeContentView, .titled]
			window.title = "About Nightfall"
			window.titlebarAppearsTransparent = true
			window.titleVisibility = .hidden
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
