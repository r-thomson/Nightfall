//
//  ClockWatcher.swift
//  Nightfall
//
//  Created by Jak Tiano on 2/1/22.
//  Copyright © 2022 Ryan Thomson. All rights reserved.
//

import CoreLocation
import Foundation
import Solar
import os.log

class Transition: ObservableObject {
	@Published var theme: AppearanceTheme? = nil;
	@Published var date: Date? = nil;
	
	func isValid() -> Bool {
		return theme != nil && date != nil
	}
}

final class TransitionScheduler {

	/*
	 
	 location update
		-> update scheduler
	 
	 update scheduler
		 if FOUND_TRANSITION -> schedule next transition
		 else NO_TRANSITION || ERROR -> schedule refresh
	 
	 schedule next transition
		- wait for time
		- run transition
		-> update scheduler
	 
	 schedule refresh
		- wait for time
		-> update scheduler
	 
	 */
	
	static let shared = TransitionScheduler()
	
	var nextTransition: Transition = Transition()
	
	func activate() {
		os_log("Beginning to listen for location events", log: log)
		LocationUtility.shared.registerObserver(key: TransitionScheduler.schedulerIdentifier, observer: self)
	}
	
	func deactivate() {
		os_log("Stop listening for location events, canceling scheduled tasks", log: log)
		LocationUtility.shared.unregisterObserver(key: TransitionScheduler.schedulerIdentifier)
		scheduledBackgroundTask?.invalidate()
	}
	
	func terminate() {
		os_log("Shutting down, cancelling scheduled tasks", log: log)
		scheduledBackgroundTask?.invalidate()
	}
	
	private let log: OSLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "scheduler")
	private var scheduledBackgroundTask: NSBackgroundActivityScheduler?
	private static let schedulerIdentifier = "\(Bundle.main.bundleIdentifier!).transition-scheduler"
	
	/// Figures out the next transition that will happen at the given location
	private func updateScheduler(location: CLLocation) {
		
		DispatchQueue.global(qos: .utility).async {
			
			switch self.calculateNextTransition(location: location) {
			
			case let .valid(theme, date):
				DispatchQueue.main.sync {
					// must update this published data on main thread
					self.nextTransition.theme = theme
					self.nextTransition.date = date
				}
				self.scheduleTransition(transition: (theme, date), location: location)
				
			case .invalid, // there is no valid transition for 6 months
				 .error:   // there was an error during calculation
				DispatchQueue.main.sync {
					// must update this published data on main thread
					self.nextTransition.theme = nil
					self.nextTransition.date = nil
				}
				self.scheduleRefreshTomorrow(location: location)
			}
		}
	}
	
	/// The possible results from calculating the next transition
	private enum TransitionCalculationResult {
		case valid(theme: AppearanceTheme, date: Date)
		case invalid
		case error
	}
	
	/// Calculates the next transition for the given location from now
	private func calculateNextTransition(location: CLLocation, loops: Int = 0) -> TransitionCalculationResult {
		
		let now = Date()
		var iteration = 0
		while iteration <= 180 { // iterate up to 6 months
			
			let date = now + TimeInterval( 60 * 60 * 24 * iteration )
			
			guard let solar = Solar(for: date, coordinate: location.coordinate) else {
				return .error
			}
			
			if let sunrise = solar.sunrise, now < sunrise {
				return .valid(theme: .light, date: sunrise)
			}
			else if let sunset = solar.sunset, now < sunset {
				return .valid(theme: .dark, date: sunset)
			}
			else { // depending on date/location, there might not be a transition today
				iteration += 1
				continue
			}
		}
	
		return .invalid // couldn't find a transition for 6 months
	}
	
	private func scheduleRefreshTomorrow(location: CLLocation) {
		
		// invalidate old task, if exists
		scheduledBackgroundTask?.invalidate()
		
		let oneHour = TimeInterval( 60 * 60 )
		let oneDay = oneHour * 24
		scheduledBackgroundTask = NSBackgroundActivityScheduler(identifier: TransitionScheduler.schedulerIdentifier)
		scheduledBackgroundTask!.repeats = false
		scheduledBackgroundTask!.qualityOfService = .background
		scheduledBackgroundTask!.interval = oneDay
		scheduledBackgroundTask!.tolerance = oneHour
		scheduledBackgroundTask!.schedule() { completion in
			
			if let shouldDefer = self.scheduledBackgroundTask?.shouldDefer, shouldDefer {
				completion(.deferred)
			} else {
				// update the scheduler in 500ms
				let dispatchTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(500)
				DispatchQueue.global(qos: .utility).asyncAfter(deadline: dispatchTime) {
					self.updateScheduler(location: location)
				}
				
				completion(.finished)
			}
		}
	}
	private func scheduleTransition(transition: (theme: AppearanceTheme, date: Date ), location: CLLocation) {
		
		let theme = transition.theme
		let date = transition.date
		let secondsUntil = date.timeIntervalSinceNow;
		let tolerance = TimeInterval( 20.0 )
		
		let execDateStr = String(describing: date)
		let themeStr = theme.toString()
		
		// invalidate old task, if exists
		scheduledBackgroundTask?.invalidate()
		
		scheduledBackgroundTask = NSBackgroundActivityScheduler(identifier: TransitionScheduler.schedulerIdentifier)
		scheduledBackgroundTask!.repeats = false
		scheduledBackgroundTask!.qualityOfService = .userInitiated
		scheduledBackgroundTask!.interval = secondsUntil + (tolerance / 2)
		scheduledBackgroundTask!.tolerance = tolerance
		scheduledBackgroundTask!.schedule() { completion in
			
			if date.timeIntervalSinceNow > 0 { // not time yet, wait (why is this happening)
				os_log("EARLY: tried to run %{public}@ transition scheduled for %{public}@", log: self.log, themeStr, execDateStr)
				completion(.deferred)
				return
			}
			else {
				switch theme {
					case .light:
						Nightfall.setToLightMode()
					case .dark:
						Nightfall.setToDarkMode()
				}
				os_log("ran %{public}@ transition scheduled for %{public}@", log: self.log, themeStr, execDateStr)
				
				// update the scheduler in 500ms
				let dispatchTime = DispatchTime.now() + DispatchTimeInterval.milliseconds(500)
				DispatchQueue.global(qos: .utility).asyncAfter(deadline: dispatchTime) {
					self.updateScheduler(location: location)
				}
				
				completion(.finished)
			}
		}
		
		os_log("scheduled %{public}@ transition for %{public}f seconds +/- %{public}f after %{public}@", log: log, themeStr, secondsUntil, tolerance, String(describing: Date()))
	}
}

extension TransitionScheduler: LocationStateObserver {
	func locationStateDidChange(state: LocationState) {
		os_log("TransitionScheduler: location state changed to %{public}@, determining next transition", log: log, String(describing: state))
		scheduledBackgroundTask?.invalidate()
		if let location = state.location {
			self.updateScheduler(location: location)
		}
	}
}
