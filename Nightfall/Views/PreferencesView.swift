//
//  PreferencesView.swift
//  Nightfall
//
//  Copyright © 2019 Ryan Thomson. All rights reserved.
//

import SwiftUI

struct PreferencesView: View {
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
	
	var body: some View {
		VStack {
			VStack(alignment: .leading) {
				VStack(alignment: .leading, spacing: 2) {
					Toggle("Animated transition", isOn: $useTransition.value)
					
					Text("Requires screen recording permission")
						.font(.system(size: 9))
						.foregroundColor(.secondary)
						.padding(.leading, 18)
				}
				
				Toggle("Start Nightfall at login", isOn: $startAtLogin.value)
				
				Toggle("Check for new versions", isOn: $checkForUpdates.value)
				
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
	}
}

#if DEBUG
struct PreferencesViewPreview: PreviewProvider {
	static var previews: some View {
		PreferencesView()
	}
}
#endif
