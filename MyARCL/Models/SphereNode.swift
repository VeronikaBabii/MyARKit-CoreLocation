//
//  SphereNode.swift
//  MyARCL
//
//  Created by Veronika Babii on 14.03.2021.
//

import CoreLocation
import ARKit

class SphereNode: SCNNode {
    
    // MARK: - Properties
    
    let title: String
    var location: CLLocation
    var anchor: ARAnchor?
    
    // MARK: - Init
    
    init(title: String, location: CLLocation) {
        self.title = title
        self.location = location
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    func addSphere(radius: CGFloat, color: UIColor) {
        let sphere = SCNSphere(radius: radius)
        sphere.firstMaterial?.diffuse.contents = color
        
        let sphereNode = SCNNode(geometry: sphere)
        addChildNode(sphereNode)
    }
    
    func addLabelSphere(radius: CGFloat, text: String, color: UIColor) {
        let text = SCNText(string: text, extrusionDepth: 0.05)
        text.font = UIFont (name: "HelveticaNeue-Medium", size: 1.4)
        text.firstMaterial?.diffuse.contents = UIColor.systemPink
        let _textNode = SCNNode(geometry: text)
        
        let sphere = SCNSphere(radius: radius)
        sphere.firstMaterial?.diffuse.contents = color
        let sphereNode = SCNNode(geometry: sphere)
        
        let textNode = SCNNode()
        textNode.addChildNode(_textNode)
        textNode.position = sphereNode.position
        
        addChildNode(sphereNode)
        addChildNode(textNode)
    }
}
