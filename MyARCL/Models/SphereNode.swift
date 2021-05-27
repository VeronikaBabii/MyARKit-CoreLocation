//
//  SphereNode.swift
//  MyARCL
//
//  Created by Veronika on 14.03.2021.
//

import CoreLocation
import ARKit

class SphereNode: SCNNode {
    
    var anchor: ARAnchor?
    
    let text: String
    
    var location: CLLocation!
    
    init(title: String, location: CLLocation) {
        self.text = title
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // simple sphere node
    func addSphere(radius: CGFloat, color: UIColor) {
        
        let bubble = SCNSphere(radius: radius)
        bubble.firstMaterial?.diffuse.contents = color
        
        let sphereNode = SCNNode(geometry: bubble)
        
        addChildNode(sphereNode)
    }
    
    // sphere node with text
    func addLabelSphere(radius: CGFloat, text: String, color: UIColor) {
        
        let text = SCNText(string: text, extrusionDepth: 0.05)
        text.font = UIFont (name: "HelveticaNeue-Medium", size: 1.4)
        text.firstMaterial?.diffuse.contents = UIColor.systemPink
        let textNode1 = SCNNode(geometry: text)
        
        let bubble = SCNSphere(radius: radius)
        bubble.firstMaterial?.diffuse.contents = color
        let sphereNode = SCNNode(geometry: bubble)
        
        let textNode = SCNNode()
        textNode.addChildNode(textNode1)
        textNode.position = sphereNode.position
        
        addChildNode(sphereNode)
        addChildNode(textNode)
    }
}
