//
//  BackMapVC.swift
//  MyARCL
//
//  Created by Veronika Babii on 30.03.2021.
//

import UIKit

class BackMapViewController: UIViewController {
    
    // MARK: - Properties
    
    var backMapView = UIView()
    
    var mapsearchVC: MapSearchViewController!
    var navVC: NavigationViewController!
    
    var currentEmbeddedVC: UIViewController {
        didSet {
            removeChild(controller: oldValue)
            embedChild(currentEmbeddedVC, view: backMapView)
        }
    }
    
    // MARK: - Init
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.currentEmbeddedVC = UIViewController()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.currentEmbeddedVC = UIViewController()
        super.init(coder: aDecoder)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = MapSearchViewController()
        self.mapsearchVC = vc
        self.mapsearchVC.delegate = self
        currentEmbeddedVC = mapsearchVC
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        edgesForExtendedLayout = []
        
        DispatchQueue.main.async {
            self.view.add(self.backMapView)
            self.backMapView.translatesAutoresizingMaskIntoConstraints = false
            
            self.backMapView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor).isActive = true
            self.backMapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
            self.backMapView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
            self.backMapView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
            
            self.backMapView.layoutIfNeeded()
            self.backMapView.backgroundColor = .blue
        }
    }
}

// MARK: - Extensions

extension BackMapViewController: MapSearchVCDelegate {
    
    func navigateInAR(data: [RouteLeg]) {
        let vc = NavigationViewController()
        vc.routeData = data
        self.navVC = vc
        currentEmbeddedVC = navVC
    }
}
