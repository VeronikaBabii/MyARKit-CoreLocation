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
            let storyboard = UIStoryboard(name: "BackMapStoryboard", bundle: nil)
            let backMapVC = storyboard.instantiateViewController(withIdentifier: "BackMapVC")
            navigationController.pushViewController(backMapVC, animated: true)
            
        case .mapSearch:
            let storyboard = UIStoryboard(name: "MapSearchStoryboard", bundle: nil)
            let mapSearchVC = storyboard.instantiateViewController(withIdentifier: "MapSearchVC")
            navigationController.pushViewController(mapSearchVC, animated: true)
            
        case .navigation:
            let storyboard = UIStoryboard(name: "NavigationStoryboard", bundle: nil)
            let navigationVC = storyboard.instantiateViewController(withIdentifier: "NavVC")
            navigationController.pushViewController(navigationVC, animated: true)
        }
    }
}

