//
//  Line.swift
//  MeasureMove
//
//  Created by Ahmed Nimra on 27.06.18.
//  Copyright © 2018 Ahmed Nimra. All rights reserved.
//


import SceneKit
import ARKit


//to do ..make a switch button
enum DistanceUnit {
    
    case centimeter
    case meter
    
    var fator: Float {
        switch self {
        case .centimeter:
            return 100.0
            
        case .meter:
            return 1.0
        }
    }
    
    var unit: String {
        switch self {
        case .centimeter:
            return "cm"
            
        case .meter:
            return "m"
        }
    }
    
    var title: String {
        switch self {
        case .centimeter:
            return "Centimeter"
            
        case .meter:
            return "Meter"
        }
    }
}

final class Line {
    fileprivate var color: UIColor = .white
    
    fileprivate var startNode: SCNNode!
    fileprivate var endNode: SCNNode!
    fileprivate var background: SCNPlane!
    fileprivate var text: SCNText!
    fileprivate var textNode: SCNNode!
    fileprivate var lineNode: SCNNode?
    fileprivate var planeNode: SCNNode!
    fileprivate var planes: [SCNNode] = []

    
    fileprivate let sceneView: ARSCNView!
    fileprivate let startVector: SCNVector3!
    fileprivate let unit: DistanceUnit!
    
    
    init(sceneView: ARSCNView, startVector: SCNVector3, unit: DistanceUnit) {
        self.sceneView = sceneView
        self.startVector = startVector
        self.unit = unit
        
        let dot = SCNSphere(radius: 0.5)
        dot.firstMaterial?.diffuse.contents = color
        dot.firstMaterial?.lightingModel = .constant
        dot.firstMaterial?.isDoubleSided = true
        startNode = SCNNode(geometry: dot)
        startNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        startNode.position = startVector
        startNode.eulerAngles.x =  -.pi / 2
        sceneView.scene.rootNode.addChildNode(startNode)
     
        
       // let plane = SCNPlane(width: CGFloat(0.05), height: CGFloat(0.05))
        //plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.75)
        //let planeNode = SCNNode(geometry: plane)
        //planeNode.position = SCNVector3Make(startVector.x, startVector.y, startVector.z)
        //planeNode.eulerAngles.x = -.pi / 2
        
        //sceneView.scene.rootNode.addChildNode(planeNode)
        
        endNode = SCNNode(geometry: dot)
        endNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        text = SCNText(string: "", extrusionDepth: 0.1)
        text.font = .systemFont(ofSize: 5)
        text.firstMaterial?.diffuse.contents = color
        text.alignmentMode  = kCAAlignmentCenter
        text.truncationMode = kCATruncationMiddle
        text.firstMaterial?.isDoubleSided = true
        
        let textWrapperNode = SCNNode(geometry: text)
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)
        textWrapperNode.scale = SCNVector3(1/500.0, 1/500.0, 1/500.0)
        
        textNode = SCNNode()
        textNode.addChildNode(textWrapperNode)
        let constraint = SCNLookAtConstraint(target: sceneView.pointOfView)
        constraint.isGimbalLockEnabled = true
        textNode.constraints = [constraint]
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func update(to vector: SCNVector3) {
        lineNode?.removeFromParentNode()
        lineNode = startVector.line(to: vector, color: color)
        sceneView.scene.rootNode.addChildNode(lineNode!)
        text.string = distance(to: vector)
        textNode.position = SCNVector3((startVector.x+vector.x)/2.0, (startVector.y+vector.y)/2.0, (startVector.z+vector.z)/2.0)
    
        endNode.position = vector
        if endNode.parent == nil {
            sceneView?.scene.rootNode.addChildNode(endNode)
            
        }
    }
    
    func distance(to vector: SCNVector3) -> String {
        return String(format: "%.2f%@", startVector.distance(from: vector) * unit.fator, unit.unit)
    }
    
    func removeFromParentNode() {
        startNode.removeFromParentNode()
        lineNode?.removeFromParentNode()
        endNode.removeFromParentNode()
        textNode.removeFromParentNode()
    }
}
