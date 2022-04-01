//
//  CLLocationDegreesExtension.swift
//  MyARCL
//
//  Created by Veronika Babii on 01.04.2022.
//

import CoreLocation

extension CLLocationDegrees {
    
    func roundToDouble() -> Double {
        return Double(self).rounded(to: 6)
    }
}
