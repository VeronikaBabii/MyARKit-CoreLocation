//
//  MKRouteStep.swift
//  MyARCL
//
//  Created by Veronika Babii on 27.03.2022.
//

import MapKit
import CoreLocation

extension MKRoute.Step {
    func locationFromStep() -> CLLocation {
        return CLLocation(latitude: polyline.coordinate.latitude,
                          longitude: polyline.coordinate.longitude)
    }
}
