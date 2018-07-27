//
//  CustomPlane.swift
//  MeasureMove
//
//  Created by Ahmed Nimra on 06.07.18.
//  Copyright © 2018 Ahmed Nimra. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

let WALL_TEXT_SIZE_MULP:CGFloat = 100

class CustomPlane {
    
    static let HEIGHT:CGFloat = 3.0
    
    class func wallMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.darkGray
        mat.transparency = 0.5
        
        mat.isDoubleSided = true
        return mat
    }
    
    class func maskMaterial() -> SCNMaterial {
        let maskMaterial = SCNMaterial()
        maskMaterial.diffuse.contents = UIColor.white
        
        maskMaterial.colorBufferWriteMask = SCNColorMask(rawValue: 0)
        

        maskMaterial.isDoubleSided = true
        return maskMaterial
    }
    
    
    class func node(from:SCNVector3,
                    to:SCNVector3) -> SCNNode {
        let distance = from.distance(vector: to)
        
        let wall = SCNPlane(width: CGFloat(distance),
                            height: HEIGHT)
        wall.firstMaterial = wallMaterial()
        let node = SCNNode(geometry: wall)
        

        
        // get center point
        node.position = SCNVector3(from.x + (to.x - from.x) * 0.5,
                                   from.y + Float(HEIGHT) * 0.5,
                                   from.z + (to.z - from.z) * 0.5)
        

        node.eulerAngles = SCNVector3(0,
                                      -atan2(to.x - node.position.x, from.z - node.position.z) - Float.pi * 0.5,
                                      0)
        node.castsShadow = false
        
        return node
    }
}


