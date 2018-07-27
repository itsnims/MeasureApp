//
//  TrackingNode.swift
//  MeasureMove
//
//  Created by Ahmed Nimra on 06.07.18.
//  Copyright © 2018 Ahmed Nimra. All rights reserved.
//

import Foundation
import SceneKit

class TrackingNode {
    class private func startNode() -> SCNNode {
        let sphere = SCNSphere(radius: 0.02)
        sphere.firstMaterial?.diffuse.contents = UIColor.green
        return SCNNode(geometry: sphere)
    }
    
    class private func endNode() -> SCNNode {
        let sphere = SCNSphere(radius: 0.02)
        sphere.firstMaterial?.diffuse.contents = UIColor.blue
        return SCNNode(geometry: sphere)
    }
    
    class func node(from:SCNVector3, to:SCNVector3?) -> SCNNode {
        let node = SCNNode()
        
        let startNode = self.startNode()
        startNode.position = from
        node.addChildNode(startNode)
        
        if let to = to {
            let endNode = self.endNode()
            endNode.position = to
            node.addChildNode(endNode)
            
         // calls the method from the customplane class
            node.addChildNode(CustomPlane.node(from: from, to: to))
        }
        
        return node
    }
}
