//
//  PreferencesView.swift
//  Nightfall
//
//  Copyright © 2019 Ryan Thomson. All rights reserved.
//

import SwiftUI

struct PreferencesView: View {
	private static var durationFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.minimum = 0.0
		formatter.maximum = 5.0
		formatter.maximumFractionDigits = 1
		return formatter
	}()
	
	/// Opens the Keyboard pane in System Preferences
	private func openSystemKeyboardPrefs() {
		let url = URL(fileURLWithPath: "/System/Library/PreferencePanes/Keyboard.prefPane")
		NSWorkspace.shared.open(url)
	}
	
	@ObservedObject private var useFade =
		ObservableUserDefault<Bool>(UserDefaults.Keys.useFade)
	@ObservedObject private var fadeDelay =
		ObservableUserDefault<Double>(UserDefaults.Keys.fadeDelay)
	@ObservedObject private var fadeDuration =
		ObservableUserDefault<Double>(UserDefaults.Keys.fadeDuration)
	@ObservedObject private var startAtLogin =
		ObservableUserDefault<Bool>(UserDefaults.Keys.startAtLogin)
	@ObservedObject private var checkForUpdates =
		ObservableUserDefault<Bool>(UserDefaults.Keys.checkForUpdates)
	
	var body: some View {
		VStack {
			VStack(alignment: .leading) {
				Toggle("Smooth transition", isOn: $useFade.value)
				
				VStack(spacing: 6) {
					DurationField(label: "Delay", value: $fadeDelay.value)
					DurationField(label: "Duration", value: $fadeDuration.value)
				}
				.disabled(!useFade.value)
				.controlSize(.small)
				.padding(.leading, 24)
				
				Text("Requires screen recording permission")
					.font(.system(size: 9))
					.foregroundColor(.secondary)
					.frame(maxWidth: .infinity, alignment: .center)
				
				Toggle("Start Nightfall at login", isOn: $startAtLogin.value)
				
				Toggle("Check for new versions", isOn: $checkForUpdates.value)
				
			}
			
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
		.frame(width: 225)
	}
	
	private struct DurationField: View {
		let label: String
		@Binding var value: Double
		
		let formatter = PreferencesView.durationFormatter
		
		var body: some View {
			HStack(spacing: 2) {
				Text("\(label):")
					.frame(maxWidth: 55, alignment: .leading)
				
				TextField("", value: $value, formatter: formatter)
					.multilineTextAlignment(.trailing)
					.frame(maxWidth: 45)
				
				Stepper(label, value: $value, in: 0...5, step: 0.1)
					.labelsHidden()
				
				Text("seconds")
			}
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
