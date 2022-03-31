//
//  CLLocationExt.swift
//  MyARCL
//
//  Created by Veronika on 14.03.2021.
//

import CoreLocation

extension CLLocation {
    
    func mostAccurateLocationFrom(_ locations: [CLLocation]) -> CLLocation {
        let sort = locations.sorted(by: {
            if $0.horizontalAccuracy == $1.horizontalAccuracy { return $0.timestamp > $1.timestamp }
            return $0.horizontalAccuracy < $1.horizontalAccuracy
        })
        return sort.first!
    }
    
    func angleBetweenThisLocation(and destinationLocation: CLLocation) -> Double {
        let currLatitude = self.coordinate.latitude.toRadians()
        let curLongitude = self.coordinate.longitude.toRadians()
        
        let destinationLatitude = destinationLocation.coordinate.latitude.toRadians()
        let destinationLongitude = destinationLocation.coordinate.longitude.toRadians()
        
        let y = sin(destinationLongitude - curLongitude) * cos(destinationLatitude)
        let x = cos(currLatitude) * sin(destinationLatitude) - sin(currLatitude) * cos(destinationLatitude) * cos(destinationLongitude - curLongitude)
        let angleInRadian = atan2(y,x)
        
        return angleInRadian
    }
}
