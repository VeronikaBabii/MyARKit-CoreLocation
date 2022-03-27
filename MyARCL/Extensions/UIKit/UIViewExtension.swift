//
//  UIViewExtension.swift
//  MyARCL
//
//  Created by Veronika Babii on 30.03.2021.
//

import UIKit

// TODO: all move to UIViewControlller extension

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
