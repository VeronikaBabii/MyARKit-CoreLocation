//
//  MainVCCoord.swift
//  MyARCL
//
//  Created by Veronika Babii on 04.05.2021.
//

import UIKit

class MainVCCoord: VCCoordinator {
    
    var window: UIWindow
    
    internal weak var delegate: VCCoordinatorDelegate?
    
    var rootVC: RootVC!
    
    var rootController: UINavigationController {
        return UINavigationController(rootViewController: rootVC)
    }
    
    var coordType: CoordinatorType {
        didSet {
            if let storyboard = try? UIStoryboard(.main) {
                let viewController: MainVC = storyboard.instantiateViewController()
                rootVC = viewController
            }
        }
    }
    
    init(w: UIWindow) {
        self.window = w
        coordType = .main
    }
    
    func show() {
        window.rootViewController = rootController
        window.makeKeyAndVisible()
    }
}

