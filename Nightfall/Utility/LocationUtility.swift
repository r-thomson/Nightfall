//
//  LocationUtility.swift
//  Nightfall
//
//  Created by Jak Tiano on 2/2/22.
//  Copyright © 2022 Ryan Thomson. All rights reserved.
//

import Foundation
import CoreLocation

enum LocationAuthorization {
	case authorized
	case unset
	case needUserAction
}

protocol LocationObserver {
	func authorizationDidChange(authorization: LocationAuthorization);
	func locationDidChange(location: CLLocationCoordinate2D?);
}

class LocationUtility: NSObject {
	
	static let shared = LocationUtility()
	var location: CLLocationCoordinate2D? = nil {
		didSet {
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
		print("initialized location utility with \(authorized)")
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
		print("location authorization requested: current = \(authorized)")
		if authorized == .unset {
			print("asking for permission: before = \(authorized)")
			self.locationManager.requestWhenInUseAuthorization()
			print("asked for permission: after = \(authorized)")
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
		print("location utility updated authorization status to \(authorized)")
	}
	
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let loc = manager.location?.coordinate else { return }
		self.location = loc
	}
}
