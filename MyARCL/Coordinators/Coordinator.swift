//
//  Coordinator.swift
//  MyARCL
//
//  Created by Veronika on 14.03.2021.
//

import UIKit

protocol Coordinator: class { }

protocol CoordinatorDelegate: class { }

enum CoordinatorType {
    case main, backMap, mapsearch, nav
}
