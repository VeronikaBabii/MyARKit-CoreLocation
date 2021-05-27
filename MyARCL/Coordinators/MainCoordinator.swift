//
//  MainCoordinator.swift
//  MyARCL
//
//  Created by Veronika on 14.03.2021.
//

import UIKit

protocol AppCoordinator: Coordinator {
    
    var delegate: VCCoordinatorDelegate? { get set }
    
    var childrenCoords: [VCCoordinator] { get set }
}

class MainCoordinator: AppCoordinator {
    
    weak var delegate: VCCoordinatorDelegate?
    
    internal var childrenCoords: [VCCoordinator] = []
    
    var window: UIWindow
    
    init(w: UIWindow) {
        self.window = w
        transToCoord(type: .main)
    }
    
    func addChildrenCoord(_ coord: VCCoordinator) {
        coord.delegate = self
        childrenCoords.append(coord)
    }
}

extension MainCoordinator: VCCoordinatorDelegate {
    
    func transToCoord(type: CoordinatorType) {
        
        childrenCoords.removeAll()
        
        switch type {
        
        case .main:
            print("to main")
            let mainCoord = MainVCCoord(w: window)
            mainCoord.coordType = .main
            addChildrenCoord(mainCoord)
            mainCoord.delegate = self
            mainCoord.show()
            
        case .backMap:
            print("to backMap")
            let backMapCoord = BackMapVCCoord(w: window)
            backMapCoord.coordType = .backMap
            addChildrenCoord(backMapCoord)
            backMapCoord.delegate = self
            backMapCoord.show()
            
        case .mapsearch:
            print("to mapsearch")
            let mapSearchCoord = MapSearchVCCoord(w: window)
            mapSearchCoord.coordType = .mapsearch
            addChildrenCoord(mapSearchCoord)
            mapSearchCoord.delegate = self
            mapSearchCoord.show()
            
        case .nav:
            print("to nav")
            let navCoord = NavVCCoord(w: window)
            navCoord.coordType = .nav
            addChildrenCoord(navCoord)
            navCoord.show()
        }
    }
}
