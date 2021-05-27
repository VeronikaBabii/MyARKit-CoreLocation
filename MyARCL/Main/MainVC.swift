//
//  MainVC.swift
//  MyARCL
//
//  Created by Veronika Babii on 04.05.2021.
//

import UIKit

final class MainVC: UIViewController, Controller {
    
    var coordType: CoordinatorType = .main
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBAction func toBackMapTapped(_ sender: UIButton) {
        print("tapped")
        let vc: BackMapVC = BackMapVC()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        design()
    }
    
    func design() {
        
        let bezierPath = UIBezierPath(roundedRect: startButton.bounds, cornerRadius: 15)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = bezierPath.cgPath
        startButton.layer.mask = maskLayer
    }
}
