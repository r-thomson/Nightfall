import Cocoa
import SwiftUI

final class PreferencesPopover: NSPopover, NSPopoverDelegate {
	static let shared = PreferencesPopover()

	let view = PreferencesView()

	override init() {
		super.init()

		self.behavior = .transient
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func show(statusButton: NSStatusBarButton) {
		show(relativeTo: statusButton.bounds, of: statusButton, preferredEdge: .minY)
	}

	override func show(
		relativeTo positioningRect: NSRect, of positioningView: NSView,
		preferredEdge: NSRectEdge
	) {
		// I thought this would go in popoverWillShow, but that causes a runtime exception
		// It seems that popoverWillShow is called after show() checks the contentViewController
		contentViewController = contentViewController ?? NSHostingController(rootView: view)

		super.show(
			relativeTo: positioningRect, of: positioningView,
			preferredEdge: preferredEdge)
	}

	func popoverDidClose(_ notification: Notification) {
		contentViewController = nil
	}
}
