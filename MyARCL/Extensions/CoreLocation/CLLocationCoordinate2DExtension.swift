//
//  CLLocationCoordinate2DExtension.swift
//  MyARCL
//
//  Created by Veronika Babii on 27.03.2022.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    func createCoordinateFor(_ bearing: Double, _ distance: Double) -> CLLocationCoordinate2D {
        let distRadiansLat = distance / 6373000.0
        let distRadiansLong = distance /  5602900.0
        
        let currLattitude = self.latitude.toRadians()
        let currLongitude = self.longitude.toRadians()
        
        let lattitude = asin(sin(currLattitude) * cos(distRadiansLat) +
                             cos(currLattitude) * sin(distRadiansLat) * cos(bearing))
        
        let longitude = currLongitude + atan2(sin(bearing) * sin(distRadiansLong) * cos(currLattitude),
                                              cos(distRadiansLong) - sin(currLattitude) * sin(lattitude))
        
        return CLLocationCoordinate2D(latitude: lattitude.toDegrees(), longitude: longitude.toDegrees())
    }
    
    static func getIntermediateLocations(from currentLocation: CLLocation, to destinationLocation: CLLocation) -> [CLLocationCoordinate2D] {
        var intermediateLocations = [CLLocationCoordinate2D]()
        let distanceBetweenNodes: Float = 18
        var distanceBetweenCurrAndDest = Float(destinationLocation.distance(from: currentLocation))
        let bearingCurrToDest = currentLocation.angleBetweenThisLocation(and: destinationLocation)
        
        while distanceBetweenCurrAndDest > 18 {
            distanceBetweenCurrAndDest -= distanceBetweenNodes
            let location = currentLocation.coordinate.createCoordinateFor(Double(bearingCurrToDest), Double(distanceBetweenCurrAndDest))
            if !intermediateLocations.contains(location) { intermediateLocations.append(location) }
        }
        return intermediateLocations
    }
}
