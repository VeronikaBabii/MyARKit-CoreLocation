//
//  DoubleExt.swift
//  MyARCL
//
//  Created by Veronika on 14.03.2021.
//

import Foundation

extension Double {
    
    func toRadians() -> Double { return self * .pi / 180.0 }
    
    func toDegrees() -> Double { return self * 180.0 / .pi }
    
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
