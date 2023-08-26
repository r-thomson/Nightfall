import SwiftUI

extension View {
	/// Shows a specified cursor when the mouse pointer is over the view
	func cursor(_ cursor: NSCursor) -> some View {
		return self.onHover { (inside) in
			if inside {
				cursor.push()
			} else {
				cursor.pop()
			}
		}
	}
}
