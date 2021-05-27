//
//  MapSearchVCCoord.swift
//  MyARCL
//
//  Created by Veronika on 14.03.2021.
//

import UIKit

class MapSearchVCCoord: VCCoordinator {
    
    var window: UIWindow
    
    internal weak var delegate: VCCoordinatorDelegate?
    
    var rootVC: RootVC!
    
    var rootController: UINavigationController {
        return UINavigationController(rootViewController: rootVC)
    }
    
    var coordType: CoordinatorType {
        didSet {
            if let storyboard = try? UIStoryboard(.mapsearch) {
                let viewController: MapSearchVC = storyboard.instantiateViewController()
                rootVC = viewController
            }
        }
    }
    
    init(w: UIWindow) {
        self.window = w
        coordType = .mapsearch
    }
    
    func show() {
        window.rootViewController = rootController
        window.makeKeyAndVisible()
    }
}
