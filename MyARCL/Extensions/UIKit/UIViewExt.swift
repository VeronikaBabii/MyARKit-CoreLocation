//
//  UIViewExt.swift
//  MyARCL
//
//  Created by Veronika on 30.03.2021.
//

import UIKit

extension UIView {
    
    func add(_ subviews: UIView...) {
        subviews.forEach(addSubview)
    }
    
    func constrain(to view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        view.add(self)
        
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

extension UIViewController {
    
    func embedChild(controller: UIViewController, view: UIView) {
        self.addChild(controller)
        controller.view.constrain(to: view)
        controller.didMove(toParent: self)
    }
    
    func removeChild(controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }
}
