//
//  RouteLeg.swift
//  MyARCL
//
//  Created by Veronika Babii on 29.03.2021.
//

import CoreLocation

struct RouteLeg: Equatable {
    var directions: String
    var coordinates: [CLLocationCoordinate2D]
    
    static func == (lhs: RouteLeg, rhs: RouteLeg) -> Bool {
        return lhs.directions == rhs.directions
    }
}
