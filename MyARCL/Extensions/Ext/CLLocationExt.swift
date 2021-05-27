//
//  CLLocationExt.swift
//  MyARCL
//
//  Created by Veronika on 14.03.2021.
//

import CoreLocation

extension CLLocation {
    
    func mostAccurateLocFrom(locations: [CLLocation]) -> CLLocation {
        
        let sort = locations.sorted(by: {
            
            if $0.horizontalAccuracy == $1.horizontalAccuracy { return $0.timestamp > $1.timestamp }
            
            let morePrecise = $0.horizontalAccuracy < $1.horizontalAccuracy
            
            return morePrecise
        })
        return sort.first!
    }
    
    /// angle between location and destination location
    func angleToLoc(_ destLocation: CLLocation) -> Double {
        
        let lat1 = self.coordinate.latitude.toRadians()
        let lon1 = self.coordinate.longitude.toRadians()
        
        let lat2 = destLocation.coordinate.latitude.toRadians()
        let lon2 = destLocation.coordinate.longitude.toRadians()
        
        let angleInRadian = atan2(sin(lon2 - lon1) * cos(lat2),
                                  cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(lon2 - lon1))
        
        return angleInRadian
    }
}

// MARK: -
extension CLLocationCoordinate2D: Equatable {
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude
            && lhs.longitude == rhs.longitude
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
    
    static func getInterLocs(currLocation: CLLocation,
                             destLocation: CLLocation) -> [CLLocationCoordinate2D] {
        
        var interLocs = [CLLocationCoordinate2D]()
        
        let distanceBetweenNodes: Float = 18
        
        var distanceCurrAndDest = Float(destLocation.distance(from: currLocation))
        
        let bearingCurrToDest = currLocation.angleToLoc(destLocation)
        
        while distanceCurrAndDest > 18 {
            
            distanceCurrAndDest -= distanceBetweenNodes
            
            let loc = currLocation.coordinate.createCoordinateFrom(Double(bearingCurrToDest),
                                                                   Double(distanceCurrAndDest))
            
            if !interLocs.contains(loc) { interLocs.append(loc) }
        }
        return interLocs
    }
}
