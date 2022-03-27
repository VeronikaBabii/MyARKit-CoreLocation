//
//  UIStoryboardExtension.swift
//  MyARCL
//
//  Created by Veronika Babii on 14.03.2021.
//

import UIKit

//extension UIStoryboard {
//
//    enum Storyboard: String {
//        case main, backMap, mapsearch, navigation
//
//        var filename: String {
//            return rawValue.capitalized
//        }
//    }
//
//    convenience init(_ storyboard: Storyboard, bundle: Bundle? = nil) throws {
//        self.init(name: storyboard.filename, bundle: bundle)
//    }
//
//    func instantiateViewController<T: UIViewController>() -> T {
//        return (self.instantiateViewController(withIdentifier: T.storyboardIdentifier) as? T)!
//    }
//}
//
//extension UIViewController: StoryboardIdentifiable { }
//
//protocol StoryboardIdentifiable {
//    static var storyboardIdentifier: String { get }
//}
//
//extension StoryboardIdentifiable where Self: UIViewController {
//    static var storyboardIdentifier: String {
//        return String(describing: self)
//    }
//}
