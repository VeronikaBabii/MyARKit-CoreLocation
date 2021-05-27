//
//  AlertMessage.swift
//  MyARCL
//
//  Created by Veronika on 14.03.2021.
//

import UIKit

protocol AlertMessage {
    func showAlert(title: String, message: String)
}

extension AlertMessage where Self: UIViewController {
    
    func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okay = UIAlertAction(title: "Okay", style: .default, handler: nil)
        
        alert.addAction(okay)
        present(alert, animated: true)
    }
}
