//
//  AlertMessage.swift
//  MyARCL
//
//  Created by Veronika Babii on 14.03.2021.
//

import UIKit

protocol AlertMessage {
    func showAlert(title: String, message: String)
}

extension AlertMessage where Self: UIViewController {
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alert.addAction(okayAction)
        present(alert, animated: true)
    }
}
