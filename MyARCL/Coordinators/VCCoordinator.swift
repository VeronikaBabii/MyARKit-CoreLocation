//
//  ControllerCoordinator.swift
//  MyARCL
//
//  Created by Veronika on 14.03.2021.
//

import UIKit

protocol Controller: class {
    var coordType: CoordinatorType { get }
}

typealias RootVC = UIViewController & Controller

protocol VCCoordinator: Coordinator {
    
    var window: UIWindow { get set }
    
    var rootVC: RootVC! { get }
    
    var delegate: VCCoordinatorDelegate? { get set }
}

protocol VCCoordinatorDelegate: CoordinatorDelegate {
    
    func transToCoord(type: CoordinatorType)
}
