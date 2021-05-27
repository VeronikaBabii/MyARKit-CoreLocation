//
//  RouteLeg.swift
//  MyARCL
//
//  Created by Veronika on 29.03.2021.
//

import CoreLocation

struct RouteLeg {
    
    var directions: String
    
    var coordinates: [CLLocationCoordinate2D]
    
}

extension RouteLeg: Equatable {
    
    static func == (lhs: RouteLeg, rhs: RouteLeg) -> Bool {
        return lhs.directions == rhs.directions
    }
}
