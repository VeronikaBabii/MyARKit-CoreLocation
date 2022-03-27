//
//  AppDelegate.swift
//  MyARCL
//
//  Created by Veronika Babii on 14.03.2021.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator!
    
    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "MainStoryboard", bundle: nil)
        let mainVC = storyboard.instantiateViewController(withIdentifier: "MainVC")
        let navController = UINavigationController(rootViewController: mainVC)
        appCoordinator = AppCoordinator(navigationController: navController)
        appCoordinator.window = window
        appCoordinator.start()
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        return true
    }
}
