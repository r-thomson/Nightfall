import KeyboardShortcuts
import SwiftUI

struct PreferencesView: View {
	/// Opens the Screen Recording privacy settings in System Settings
	private func openSystemScreenCapturePrefs() {
		if let url = URL(
			string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")
		{
			NSWorkspace.shared.open(url)
		}
	}

	@ObservedObject private var useTransition =
		ObservableUserDefault<Bool>(UserDefaults.Keys.useTransition)
	@ObservedObject private var startAtLogin =
		ObservableUserDefault<Bool>(UserDefaults.Keys.startAtLogin)
	@ObservedObject private var checkForUpdates =
		ObservableUserDefault<Bool>(UserDefaults.Keys.checkForUpdates)

	@State var hasScreenCapturePermission: Bool? = nil

	let cautionImage = NSImage(named: NSImage.cautionName)!

	var body: some View {
		VStack {
			HStack(alignment: .firstTextBaseline) {
				Text("Shortcut:")
				Spacer()
				KeyboardShortcuts.Recorder(for: .toggleDarkMode)
			}
			.padding(.bottom, 8)

			VStack(alignment: .leading) {
				VStack(alignment: .leading, spacing: 2) {
					HStack(spacing: 4) {
						Toggle("Animated transition", isOn: $useTransition.value)

						if useTransition.value && hasScreenCapturePermission == false {
							Image(nsImage: cautionImage)
								.resizable()
								.aspectRatio(contentMode: .fit)
								.frame(height: 14)
						}
					}

					Button(action: openSystemScreenCapturePrefs) {
						Text("Requires screen recording permission")
							.font(.system(size: 9))
					}
					.buttonStyle(BorderlessButtonStyle())
					.cursor(.pointingHand)
					.padding(.leading, 18)
				}

				Toggle("Start Nightfall at login", isOn: $startAtLogin.value)

				Toggle("Check for new versions", isOn: $checkForUpdates.value)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.padding()
		.frame(width: 240)
		.onAppear {
			// Check every time the preferences popup is opened
			hasScreenCapturePermission =
				PermissionUtil.checkScreenCapturePermission(canPrompt: false)
		}
	}
}

#if DEBUG
	struct PreferencesViewPreview: PreviewProvider {
		static var previews: some View {
			PreferencesView()
		}
	}
#endif
