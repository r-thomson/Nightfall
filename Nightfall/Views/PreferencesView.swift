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
	
	@ObservedObject private var useFade = ObservableUserDefault<Bool>(UserDefaults.Keys.useFade)
	@ObservedObject private var fadeDelay = ObservableUserDefault<Double>(UserDefaults.Keys.fadeDelay)
	@ObservedObject private var fadeDuration = ObservableUserDefault<Double>(UserDefaults.Keys.fadeDuration)
	
	var body: some View {
		VStack(alignment: .leading) {
			Toggle(isOn: $useFade.value) {
				Text("Smooth transition")
			}
			
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
			
			Divider()
				.padding(.vertical, 8)
			
			Text("Nightfall exposes a \"Toggle Dark Mode\" service that can have a global keyboard shortcut assigned in System Preferences.")
				.font(.system(size: 12))
				.allowsTightening(true)
			
			Button(action: openSystemKeyboardPrefs) {
				Text("Open System Preferences")
			}
			.frame(maxWidth: .infinity, alignment: .center)
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
