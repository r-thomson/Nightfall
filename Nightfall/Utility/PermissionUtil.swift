import Cocoa

enum PermissionUtil {
	static func checkScreenCapturePermission(canPrompt: Bool) -> Bool {
		if canPrompt {
			let stream = CGDisplayStream(
				display: CGMainDisplayID(),
				outputWidth: 1,
				outputHeight: 1,
				pixelFormat: Int32(kCVPixelFormatType_32BGRA),
				properties: nil,
				handler: { _, _, _, _ in })

			return stream != nil
		} else {
			// Method based on https://stackoverflow.com/questions/56597221#58985069

			guard
				let windowList = CGWindowListCopyWindowInfo(
					.excludeDesktopElements, kCGNullWindowID)
					as NSArray?
			else { return false }

			// Try to find a window with a title that is readable
			for case let windowInfo as NSDictionary in windowList {
				// Skip windows that belong to this application
				let windowPID = windowInfo[kCGWindowOwnerPID] as? pid_t
				if windowPID == NSRunningApplication.current.processIdentifier {
					continue
				}

				// Skip windows that don't require permission for their titles to be read
				guard windowInfo[kCGWindowOwnerName] as? String != "Window Server"
				else { continue }

				if windowInfo[kCGWindowName] != nil {
					return true
				}
			}

			// No windows have readable titles
			return false
		}
	}
}
