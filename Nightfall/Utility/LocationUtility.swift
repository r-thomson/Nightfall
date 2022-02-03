//
//  LocationUtility.swift
//  Nightfall
//
//  Created by Jak Tiano on 2/2/22.
//  Copyright © 2022 Ryan Thomson. All rights reserved.
//

import Foundation
import CoreLocation

import os.log;

enum LocationAuthorization {
	case authorized
	case unset
	case needUserAction
}

struct LocationState {
	let authorization: LocationAuthorization
	let location: CLLocation?
}
protocol LocationStateObserver {
	func locationStateDidChange(state: LocationState);
}

class LocationUtility: NSObject {
	
	static let shared = LocationUtility()
	
	private let locationManager = CLLocationManager()
	private let log: OSLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "location")
	
	private var observers = [String:LocationStateObserver]()
	private var authorized: LocationAuthorization {
		didSet(prevAuthorized) {
			// if authorization changed, update state
			if prevAuthorized != authorized {
				state = LocationState(authorization: authorized, location: state.location)
			}
		}
	}
	private var location: CLLocation? {
		didSet {
			// if both are nil, exit
			if location == nil, state.location == nil { return }
			
			// if both not nil and distance change is not big enough, exit
			if let new = location, let prev = state.location, new.distance(from: prev) < 25000 { return }
			
			state = LocationState(authorization: self.state.authorization, location: location)
		}
	}
	private var state: LocationState {
		didSet(prevState) {
			// when state changes, notify observers
			for (_, o) in observers {
				o.locationStateDidChange(state: LocationState(authorization: self.authorized, location: location))
			}
		}
	}
	
	override init () {
		
		// init state
		authorized = .unset
		location = nil
		state = LocationState(authorization: authorized, location: location)
		
		super.init()
		
		if CLLocationManager.locationServicesEnabled() {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
			locationManager.startUpdatingLocation()
		}
		
		// determine the initial authorization status
		if #available(macOS 11.0, *) {
			// this will get handled in locationManagerDidChangeAuthorization for (>= macOS 11.0)
		} else {
			switch CLLocationManager.authorizationStatus() {
			case .authorized, .authorizedAlways, .authorizedWhenInUse:
				authorized = .authorized
			case .notDetermined:
				authorized = .unset
			default:
				authorized = .needUserAction
			}
		}
		
		os_log("initialized location utility with %{public}@", log: log, String(describing: authorized))
	}
	
	func registerObserver(key: String, observer: LocationStateObserver) {
		observers[key] = observer
		observer.locationStateDidChange(state: self.state)
	}
	func unregisterObserver(key: String) {
		observers.removeValue(forKey: key)
	}
	
	func isAuthorized() -> LocationAuthorization {
		return authorized
	}
	
	func requestAuthorization() {
		os_log("location authorization requested: current = %{public}@", log: log, String(describing: authorized))
		if authorized == .unset {
			self.locationManager.requestWhenInUseAuthorization()
		}
	}
}

extension LocationUtility : CLLocationManagerDelegate {
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		if #available(macOS 11.0, *) {
			switch manager.authorizationStatus {
			case .authorized, .authorizedAlways, .authorizedWhenInUse:
				authorized = .authorized
			case .notDetermined:
				authorized = .unset
			default:
				authorized = .needUserAction
			}
		}
		
		os_log("location utility updated authorization status to %{public}@", log: log, String(describing: authorized))
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		self.location = locations.last
	}
}
