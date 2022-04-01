//
//  AppCoordinator.swift
//  MyARCL
//
//  Created by Veronika Babii on 27.03.2022.
//

import UIKit

class AppCoordinator: Coordinator {
    var window: UIWindow?
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        navigationController.isNavigationBarHidden = true
    }
    
    func navigate(to type: ControllerType) {
        switch type {
        case .backMap:
            let backMapVC = BackMapViewController()
            navigationController.pushViewController(backMapVC, animated: true)
            
        case .mapSearch:
            let mapSearchVC = MapSearchViewController()
            navigationController.pushViewController(mapSearchVC, animated: true)
            
        case .navigation:
            let navigationVC = NavigationViewController()
            navigationController.pushViewController(navigationVC, animated: true)
        }
    }
}
