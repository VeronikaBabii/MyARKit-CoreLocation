//
//  DoubleExt.swift
//  MyARCL
//
//  Created by Veronika Babii on 14.03.2021.
//

import Foundation

extension Double {
    func toRadians() -> Double { self * .pi / 180.0 }
    
    func toDegrees() -> Double { self * 180.0 / .pi }
    
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
