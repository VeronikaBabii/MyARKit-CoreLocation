//
//  UIViewController.swift
//  MyARCL
//
//  Created by Veronika Babii on 27.03.2022.
//

import UIKit

extension UIViewController {
    
    func embedChild(_ vc: UIViewController, view: UIView) {
        self.addChild(vc)
        vc.view.constrain(to: view)
        vc.didMove(toParent: self)
    }
    
    func removeChild(controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }
}
