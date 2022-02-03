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
}

final class TransitionScheduler {
	
	enum State {
		case activated
		case deactivated
	}
	
	static let shared = TransitionScheduler()
	private static let OBSERVER_KEY = "autoTransitioner"
	
	var state: State = .deactivated {
		didSet {
			switch state {
			case .activated:
				LocationUtility.shared.registerObserver(key: TransitionScheduler.OBSERVER_KEY, observer: self)
			case .deactivated:
				LocationUtility.shared.unregisterObserver(key: TransitionScheduler.OBSERVER_KEY)
				os_log("canceling next transition", log: log)
				self.transitionScheduler.invalidate()
			}
		}
	}
	var nextTransition: Transition = Transition()
	
	private let log: OSLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "scheduler")
	private let transitionScheduler: NSBackgroundActivityScheduler
	private static let schedulerIdentifier = "\(Bundle.main.bundleIdentifier!).transitionCheck"
	
	init() {
		transitionScheduler = NSBackgroundActivityScheduler(identifier: TransitionScheduler.schedulerIdentifier)
	}
	
	func activate() {
		state = .activated
	}
	
	func deactivate() {
		state = .deactivated
	}
	
	private func determineNextTransition(location: CLLocation) {
		
		guard let (theme, date) = self.getNextTransition(date: Date(), location: location ) else { return }
		self.nextTransition.theme = theme
		self.nextTransition.date = date
		self.scheduleTransition(transition: self.nextTransition, location: location)
	}
	
	private func getNextTransition(date: Date, location: CLLocation, loops: Int = 0) -> (AppearanceTheme, Date)? {
		
		os_log("getting next transition (loop: %u)", log: log, Int32(loops))
		
		// make sure we don't get caught in weird infinte loops
		// if we end up more than two days out, something is wrong
		if loops > 2 { return nil }
		
		// make sure we have all this stuff
		guard let solar = Solar(for: date, coordinate: location.coordinate) else {
			os_log("can't get next transition; has no solar", log: log)
			return nil
		}
		guard let sunrise = solar.sunrise else {
			os_log("can't get next transition; has no sunrise", log: log)
			return nil
		}
		guard let sunset = solar.sunset else {
			os_log("can't get next transition; has no sunset", log: log)
			return nil
		}
		
		// get the next transition
		let now = Date()
		if now < sunrise {
			return (.light, sunrise)
		} else if now < sunset {
			return (.dark, sunset)
		} else {
			let roughlyTomorrow = now + TimeInterval( 60 * 60 * 24 )
			return getNextTransition(date: roughlyTomorrow, location: location, loops: loops + 1)
		}
	}
	
	private func scheduleTransition(transition: Transition, location: CLLocation) {
		
		guard let theme = transition.theme else { return }
		guard let date = transition.date else { return }
		
		let until = date.timeIntervalSinceNow;
		guard until > 0 else { return } // don't schedule for the past
		
		print("until = \(until)")
		print("now + until = \(Date() + until)")
		
		transitionScheduler.repeats = false
		transitionScheduler.interval = until
		transitionScheduler.tolerance = TimeInterval( 60 * 3 ) // three minute tolerance
		transitionScheduler.qualityOfService = .userInitiated
		transitionScheduler.schedule() { completion in
			os_log("running transition %{public}@ that was scheduled for TIME %{public}@: currently TIME %{public}@", log: self.log, String(describing: theme), String(describing: date), String(describing: Date()))
			switch theme {
			case .light:
				Nightfall.setToLightMode()
			case .dark:
				Nightfall.setToDarkMode()
			}
			completion(.finished)
			
			// schedule the next transition
			self.determineNextTransition(location: location)
		}
		
		os_log("scheduled transition to %{public}@ at %{public}@", log: log, String(describing: theme), String(describing: date))
	}
}

extension TransitionScheduler: LocationStateObserver {
	func locationStateDidChange(state: LocationState) {
		os_log("autotransitioner: location state changed to %{public}@, determining next transition", log: log, String(describing: state))
		transitionScheduler.invalidate()
		
		if state.authorization == .authorized, let location = state.location {
			DispatchQueue.main.async {
				self.determineNextTransition(location: location)
			}
		}
	}
}
