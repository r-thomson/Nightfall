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

final class ClockWatcher: NSObject {
    static let shared = ClockWatcher()
    
    private var location: CLLocationCoordinate2D?
    private let locationManager = CLLocationManager()

    private let transitionScheduler: NSBackgroundActivityScheduler
    private static let schedulerIdentifier = "\(Bundle.main.bundleIdentifier!).transitionCheck"
    private static let schedulerIntervalSecs = 60 * 60 * 24 // 24 hours in seconds
    
    override init() {
        transitionScheduler = NSBackgroundActivityScheduler(identifier: ClockWatcher.schedulerIdentifier)
    
        super.init()
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()

        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
        }
    }
    
    func getNextTransition(date: Date, loops: Int = 0) -> (AppearanceTheme, Date)? {
        
        // make sure we don't get caught in weird infinte loops
        // if we end up more than two days out, something is wrong
        if loops > 2 { return nil }
        
        // make sure we have all this stuff
        guard let loc = self.location else{ return nil }
        guard let solar = Solar(coordinate: loc) else { return nil }
        guard let sunrise = solar.sunrise else { return nil }
        guard let sunset = solar.sunset else { return nil }
        
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
    
    func scheduleTransition(theme: AppearanceTheme, date: Date) {
        
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
    }
    
    func determineNextTransition() {
        
        // make sure we get a valid transition back
        guard let (theme, date) = self.getNextTransition(date: Date() ) else { return }
        
        scheduleTransition(theme: theme, date: date)
    }
    
    func startWatchingClock() {
        
        // Only watch if the user has the preference enabled
        guard UserDefaults.standard.autoTransition else { return }
        
        determineNextTransition()
    }
    
    func stopWatchingClock() {
        transitionScheduler.invalidate()
    }
}

extension ClockWatcher :  CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = manager.location?.coordinate else { return }
        self.location = loc
    }
}
