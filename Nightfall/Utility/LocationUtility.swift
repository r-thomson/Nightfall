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
	
	private var locationManagerInitialized = false
	private var locationManager: CLLocationManager = CLLocationManager()
	private let log: OSLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "location")
	
	private var observers = [String:LocationStateObserver]()
	private var authorizationStatus: LocationAuthorization {
		didSet(prevAuthorized) {
			// if authorization changed, update state
			if prevAuthorized != authorizationStatus {
				state = LocationState(authorization: authorizationStatus, location: state.location)
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
				o.locationStateDidChange(state: LocationState(authorization: self.authorizationStatus, location: location))
			}
		}
	}
	
	
	func registerObserver(key: String, observer: LocationStateObserver) {
		observers[key] = observer
		observer.locationStateDidChange(state: self.state)
	}
	func unregisterObserver(key: String) {
		observers.removeValue(forKey: key)
	}
	func getAuthorizationStatus() -> LocationAuthorization {
		return authorizationStatus
	}
	func requestAuthorization() {
		os_log("location authorization requested: current = %{public}@", log: log, String(describing: authorizationStatus))
		if authorizationStatus == .unset {
			self.locationManager.requestWhenInUseAuthorization()
		}
		initLocationManager()
	}
	
	
	override init () {
		authorizationStatus = .unset
		location = nil
		state = LocationState(authorization: authorizationStatus, location: location)
		
		super.init()
	}
	
	private func initLocationManager() {
		guard locationManagerInitialized == false else { return }
		guard CLLocationManager.locationServicesEnabled() else {
			// the device itself doesn't have location services enabled
			return
		}
		
		locationManager.delegate = self
		locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
		locationManager.startUpdatingLocation()
		locationManagerInitialized = true
		
		let authStatus: CLAuthorizationStatus
		if #available(macOS 11.0, *) {
			authStatus = locationManager.authorizationStatus
		} else {
			authStatus = CLLocationManager.authorizationStatus()
		}
		switch authStatus {
		case .authorized, .authorizedAlways, .authorizedWhenInUse:
			authorizationStatus = .authorized
		case .notDetermined:
			authorizationStatus = .unset
		default:
			authorizationStatus = .needUserAction
		}
		
		os_log("initialized location manager with auth status: %{public}@", log: log, String(describing: authorizationStatus))
	}
	
}

extension LocationUtility : CLLocationManagerDelegate {
	func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
		if #available(macOS 11.0, *) {
			switch manager.authorizationStatus {
			case .authorized, .authorizedAlways, .authorizedWhenInUse:
				authorizationStatus = .authorized
			case .notDetermined:
				authorizationStatus = .unset
			default:
				authorizationStatus = .needUserAction
			}
		}
		
		os_log("location utility received authorization status of %{public}@", log: log, String(describing: authorizationStatus))
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		self.location = locations.last
	}
}
