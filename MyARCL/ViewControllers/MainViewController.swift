//
//  MainViewController.swift
//  MyARCL
//
//  Created by Veronika Babii on 04.05.2021.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupUI()
    }
    
    func setupUI() {
        let bezierPath = UIBezierPath(roundedRect: startButton.bounds, cornerRadius: 15)
        let maskLayer = CAShapeLayer()
        maskLayer.path = bezierPath.cgPath
        startButton.layer.mask = maskLayer
    }
    
    @IBAction func toBackMapTapped(_ sender: UIButton) {
        // TODO: add coordinator usage
        let vc = BackMapViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false)
    }
}
