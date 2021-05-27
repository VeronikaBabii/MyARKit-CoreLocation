//
//  Annotation.swift
//  MyARCL
//
//  Created by Veronika on 14.03.2021.
//

import MapKit

class Annotation: NSObject, MKAnnotation {
    
    var title: String?
    
    var coordinate: CLLocationCoordinate2D
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
        super.init()
    }
}
