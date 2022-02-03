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

protocol LocationObserver {
	func authorizationDidChange(authorization: LocationAuthorization);
	func locationDidChange(location: CLLocation?);
}

class LocationUtility: NSObject {
	
	static let shared = LocationUtility()
	var location: CLLocation? = nil {
		didSet(oldLocation) {
			// if no change, don't alert
			if oldLocation == location { return }
			
			// if distance change isn't big enough, don't change
			if let new = location, let old = oldLocation, new.distance(from: old) < 25000 {
				location = oldLocation
				return
			}
			
			// if meaningfully changed, alert
			for (_, o) in observers {
				o.locationDidChange(location: location)
			}
		}
	}
	let locationManager = CLLocationManager()
	
	private var observers = [String:LocationObserver]()
	private var authorized: LocationAuthorization = .unset{
		didSet {
			for (_, o) in observers {
				o.authorizationDidChange(authorization: authorized)
			}
		}
	}
	
	private let log: OSLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "location")
	
	override init () {
		
		super.init()
		
		if CLLocationManager.locationServicesEnabled() {
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
			locationManager.startUpdatingLocation()
		}
		
		// determine the initial authorization status
		if #available(macOS 11.0, *) {
			// this will get handled in locationManagerDidChangeAuthorization
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
	
	func registerObserver(key: String, observer: LocationObserver) {
		observers[key] = observer
		observer.authorizationDidChange(authorization: self.authorized)
		observer.locationDidChange(location: self.location)
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
