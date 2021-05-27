//
//  BackMapVC.swift
//  MyARCL
//
//  Created by Veronika on 30.03.2021.
//
//

import UIKit

final class BackMapVC: UIViewController, Controller {
    
    var coordType: CoordinatorType = .backMap
    
    var backMapView: UIView = UIView()
    
    var mapsearchVC: MapSearchVC!
    var navVC: NavVC!
    
    var currentEmbeddedVC: UIViewController {
        didSet {
            removeChild(controller: oldValue)
            embedChild(controller: currentEmbeddedVC, view: backMapView)
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.currentEmbeddedVC = UIViewController()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.currentEmbeddedVC = UIViewController()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let storyboard = try? UIStoryboard(.mapsearch) {
            let viewController: MapSearchVC = storyboard.instantiateViewController()
            self.mapsearchVC = viewController
            self.mapsearchVC.delegate = self
            currentEmbeddedVC = mapsearchVC
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        edgesForExtendedLayout = []
        
        DispatchQueue.main.async {
            
            self.view.add(self.backMapView)
            self.backMapView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                self.backMapView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
                self.backMapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
                self.backMapView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1),
                self.backMapView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0)
            ])
            
            self.backMapView.layoutIfNeeded()
            self.backMapView.backgroundColor = .blue
        }
    }
}

extension BackMapVC: MapSearchVCDelegate {
    
    func navigateInAR(data: [RouteLeg]) {
        
        if let storyboard = try? UIStoryboard(.navigation) {
            let viewController: NavVC = storyboard.instantiateViewController()
            viewController.routeData = data
            self.navVC = viewController
            currentEmbeddedVC = navVC
        }
    }
}
