import SwiftUI

struct PreferencesView: View {
	
	let dateFormatter: DateFormatter
	init() {
		dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .none
		dateFormatter.timeStyle = .short
	}
	
	/// Opens the Screen Recording privacy settings in System Preferences
	private func openSystemScreenCapturePrefs() {
		if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
			NSWorkspace.shared.open(url)
		}
	}
	
	/// Opens the Keyboard pane in System Preferences
	private func openSystemKeyboardPrefs() {
		let url = URL(fileURLWithPath: "/System/Library/PreferencePanes/Keyboard.prefPane")
		NSWorkspace.shared.open(url)
	}
	
	@ObservedObject private var useTransition =
		ObservableUserDefault<Bool>(UserDefaults.Keys.useTransition)
	@ObservedObject private var startAtLogin =
		ObservableUserDefault<Bool>(UserDefaults.Keys.startAtLogin)
	@ObservedObject private var checkForUpdates =
		ObservableUserDefault<Bool>(UserDefaults.Keys.checkForUpdates)
	@ObservedObject private var autoTransition =
		ObservableUserDefault<Bool>(UserDefaults.Keys.autoTransition)
	
	@ObservedObject private var transition
		= AutoTransitioner.shared.nextTransition
	
	@State var hasScreenCapturePermission: Bool? = nil
	
	var body: some View {
		VStack {
			VStack(alignment: .leading) {
				VStack(alignment: .leading, spacing: 2) {
					Toggle("Animated transition", isOn: $useTransition.value)
					
					Button(action: openSystemScreenCapturePrefs) {
						HStack(spacing: 2.5) {
							if (useTransition.value && hasScreenCapturePermission == false) {
								Image(nsImage: NSImage(named: NSImage.cautionName)!)
									.resizable()
									.aspectRatio(contentMode: .fit)
									.frame(height: 10)
							}
							
							Text("Requires screen recording permission")
								.font(.system(size: 9))
						}
					}
					.buttonStyle(BorderlessButtonStyle())
					.cursor(.pointingHand)
					.padding(.leading, 18)
				}
				
				Toggle("Start Nightfall at login", isOn: $startAtLogin.value)
				
				Toggle("Check for new versions", isOn: $checkForUpdates.value)
				
				Toggle("Auto Sunrise/Sunset", isOn: $autoTransition.value)
				HStack {
					if autoTransition.value {
						if let theme = transition.theme, let date = transition.date {
							HStack{
								Text("Next transition: \(theme.toString()) at \(self.dateFormatter.string(from:date))")
							}
						}
					} else if LocationUtility.shared.isAuthorized() != .authorized {
						Text("Requires location services permission")
					}
				}
				.font(.system(size: 9))
				.padding(.leading, 18)
				.foregroundColor(.secondary)
			}
			.frame(maxWidth: .infinity, alignment: .leading)
			
			Divider()
				.padding(.vertical, 8)
			
			VStack(alignment: .leading) {
				Text("Nightfall exposes a \"Toggle Dark Mode\" service that can have a global keyboard shortcut assigned in System Preferences.")
					.font(.system(size: 12))
					.allowsTightening(true)
					.fixedSize(horizontal: false, vertical: true)
				
				Button("Open System Preferences", action: openSystemKeyboardPrefs)
					.frame(maxWidth: .infinity, alignment: .center)
			}
		}
		.padding()
		.frame(width: 230)
		.onAppear {
			// Check every time the preferences popup is opened
			hasScreenCapturePermission = PermissionUtil.checkScreenCapturePermission(canPrompt: false)
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
