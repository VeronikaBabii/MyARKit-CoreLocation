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
    
    func createCoordinateFrom(_ bearing: Double, _ distance: Double) -> CLLocationCoordinate2D {
        
        let distRadiansLat = distance / 6373000.0
        let distRadiansLong = distance /  5602900.0
        
        let lat1 = self.latitude.toRadians()
        let lon1 = self.longitude.toRadians()
        
        let lat2 = asin(sin(lat1) * cos(distRadiansLat) + cos(lat1)
                                  * sin(distRadiansLat) * cos(bearing))
        
        let lon2 = lon1 + atan2(sin(bearing) * sin(distRadiansLong) * cos(lat1),
                                cos(distRadiansLong) - sin(lat1) * sin(lat2))
        
        return CLLocationCoordinate2D(latitude: lat2.toDegrees(), longitude: lon2.toDegrees())
    }
    
    static func getInterLocs(currLocation: CLLocation, destLocation: CLLocation) -> [CLLocationCoordinate2D] {
        
        var interLocs = [CLLocationCoordinate2D]()
        
        let distanceBetweenNodes: Float = 18
        
        var distanceCurrAndDest = Float(destLocation.distance(from: currLocation))
        
        let bearingCurrToDest = currLocation.angleBetweenCurrentLocation(and: destLocation)
        
        while distanceCurrAndDest > 18 {
            
            distanceCurrAndDest -= distanceBetweenNodes
            
            let loc = currLocation.coordinate.createCoordinateFrom(Double(bearingCurrToDest),
                                                                   Double(distanceCurrAndDest))
            
            if !interLocs.contains(loc) { interLocs.append(loc) }
        }
        return interLocs
    }
}
