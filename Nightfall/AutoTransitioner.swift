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

final class AutoTransitioner {
	
	enum State {
		case activated
		case deactivated
	}
	
	static let shared = AutoTransitioner()
	private static let OBSERVER_KEY = "autoTransitioner"
	
	var state: State = .deactivated {
		didSet {
			switch state {
			case .activated:
				LocationUtility.shared.registerObserver(key: AutoTransitioner.OBSERVER_KEY, observer: self)
			case .deactivated:
				LocationUtility.shared.unregisterObserver(key: AutoTransitioner.OBSERVER_KEY)
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
		transitionScheduler = NSBackgroundActivityScheduler(identifier: AutoTransitioner.schedulerIdentifier)
	}
	
	func activate() {
		state = .activated
	}
	
	func deactivate() {
		state = .deactivated
	}
	
	private func determineNextTransition() {
		
		guard let (theme, date) = self.getNextTransition(date: Date() ) else { return }
		self.nextTransition.theme = theme
		self.nextTransition.date = date
		self.scheduleTransition(transition: self.nextTransition)
	}
	
	private func getNextTransition(date: Date, loops: Int = 0) -> (AppearanceTheme, Date)? {
		
		os_log("getting next transition (loop: %u)", log: log, Int32(loops))
		
		// make sure we don't get caught in weird infinte loops
		// if we end up more than two days out, something is wrong
		if loops > 2 { return nil }
		
		// make sure we have all this stuff
		guard let loc = LocationUtility.shared.location else{
			os_log("can't get next transition; has no location", log: log)
			return nil
		}
		guard let solar = Solar(for: date, coordinate: loc) else {
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
			return getNextTransition(date: roughlyTomorrow, loops: loops + 1)
		}
	}
	
	private func scheduleTransition(transition: Transition ) {
		
		guard let theme = transition.theme else { return }
		guard let date = transition.date else { return }
		
		let until = date.timeIntervalSinceNow;
		guard until > 0 else { return } // don't schedule for the past
		
		transitionScheduler.repeats = false
		transitionScheduler.interval = until
		transitionScheduler.tolerance = TimeInterval( 60 * 3 ) // three minute tolerance
		transitionScheduler.schedule() { completion in
			switch theme {
			case .light:
				Nightfall.setToLightMode()
			case .dark:
				Nightfall.setToDarkMode()
			}
			completion(.finished)
			
			// schedule the next transition
			self.determineNextTransition()
		}
		
		os_log("scheduled transition to %@ at %@", log: log, String(describing: theme), String(describing: date))
	}
}

extension AutoTransitioner: LocationObserver {
	func authorizationDidChange(authorization: LocationAuthorization) {
		print("authorization changed to \(authorization), determining next transition")
		transitionScheduler.invalidate()
		DispatchQueue.main.async {
			self.determineNextTransition()
		}
	}
	
	func locationDidChange(location: CLLocationCoordinate2D?) {
		print("location changed to \(String(describing: location)), determining next transition")
		transitionScheduler.invalidate()
		DispatchQueue.main.async {
			self.determineNextTransition()
		}
	}
}
