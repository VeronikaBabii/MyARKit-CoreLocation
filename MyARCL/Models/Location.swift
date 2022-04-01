//
//  Location.swift
//  MyARCL
//
//  Created by Veronika Babii on 14.03.2021.
//

import CoreLocation

protocol LocationDelegate: AnyObject {
    func trackingLocation(for currentLocation: CLLocation)
    func trackingLocationDidFail(with error: Error)
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
}

class Location: NSObject {
    
    var locationManager: CLLocationManager?
    var delegate: LocationDelegate?
    var currentLocation: CLLocation?
    var direction: CLLocationDirection!
    
    override init() {
        super.init()
        
        locationManager = CLLocationManager()
        
        guard let locationManager = locationManager else { return }
        auth(locationManager: locationManager)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = 3
        locationManager.headingFilter = 45
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.delegate = self
    }
}

extension Location: CLLocationManagerDelegate {
        
    func auth(locationManager: CLLocationManager) {
        locationManager.requestWhenInUseAuthorization()
        
        switch(CLLocationManager.authorizationStatus()) {
        case .authorizedAlways, .authorizedWhenInUse:
            startUpdatingLocation(locationManager: locationManager)
        case .denied, .notDetermined, .restricted:
            stopUpdatingLocation(locationManager: locationManager)
        @unknown default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newDirection: CLHeading) {
        if newDirection.headingAccuracy < 0 { return }
        if newDirection.trueHeading > 0 {
            direction = newDirection.trueHeading
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach { delegate?.trackingLocation(for: $0) }
        currentLocation = manager.location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError err: Error) {
        delegate?.trackingLocationDidFail(with: err)
    }
    
    func updateLocation(currentLocation: CLLocation) {
        delegate?.trackingLocation(for: currentLocation)
    }
    
    func startUpdatingLocation(locationManager: CLLocationManager) {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func stopUpdatingLocation(locationManager: CLLocationManager) {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
}
