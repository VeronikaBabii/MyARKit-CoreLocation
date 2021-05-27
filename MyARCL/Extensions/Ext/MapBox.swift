//
//  MapBox.swift
//  MyARCL
//
//  Created by Veronika on 30.03.2021.
//

import MapKit

class MKMapCompassView: MKMapView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.opacity = 0.8
        self.backgroundColor = .white
        
        setUserTrackingMode(.followWithHeading, animated: true)
        showsCompass = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        let bezierPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.frame.width / 2)
        let maskLayer = CAShapeLayer()
        maskLayer.path = bezierPath.cgPath
        self.layer.mask = maskLayer
    }
}

extension MKRoute.Step {
    
    /// get CLLocation from a route step
    func locFromStep() -> CLLocation {
        return CLLocation(latitude: polyline.coordinate.latitude,
                          longitude: polyline.coordinate.longitude)
    }
}
