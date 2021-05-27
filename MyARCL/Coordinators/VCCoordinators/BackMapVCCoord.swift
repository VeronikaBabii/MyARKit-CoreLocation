//
//  BackMapVCCoord.swift
//  MyARCL
//
//  Created by Veronika on 30.03.2021.
//

import UIKit

class BackMapVCCoord: VCCoordinator {
    
    var window: UIWindow
    
    internal weak var delegate: VCCoordinatorDelegate?
    
    var rootVC: RootVC!
    
    var rootController: UINavigationController {
        return UINavigationController(rootViewController: rootVC)
    }
    
    var coordType: CoordinatorType {
        didSet {
            if let storyboard = try? UIStoryboard(.backMap) {
                let viewController: BackMapVC = storyboard.instantiateViewController()
                rootVC = viewController
            }
        }
    }
    
    init(w: UIWindow) {
        self.window = w
        coordType = .backMap
    }
    
    func show() {
        window.rootViewController = rootController
        window.makeKeyAndVisible()
    }
}
