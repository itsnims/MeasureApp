//
//  ARSceneManager.swift
//  MeasureMove
//
//  Created by Ahmed Nimra on 02.07.18.
//  Copyright © 2018 Ahmed Nimra. All rights reserved.
//

import Foundation
import ARKit

class ARSceneManager: NSObject {
    
    private var planes = [UUID: Plane]()
    
    var sceneView: ARSCNView?
    
    var showPlanes: Bool = true
    
    let configuration = ARWorldTrackingConfiguration()
    
    func attach(to sceneView: ARSCNView) {
        self.sceneView = sceneView
        self.sceneView?.autoenablesDefaultLighting = true
        
        self.sceneView!.delegate = self
        
        startPlaneDetection()
        configuration.isLightEstimationEnabled = true
        
        sceneView.scene.physicsWorld.gravity = SCNVector3(0, -3.0, 0)
    }
    
    
    
    
    func startPlaneDetection() {
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView?.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView?.session.run(configuration)
    }
    
    
    
    
}

extension ARSceneManager: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // we only care about planes
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        print("Found plane: \(planeAnchor)")
        
        let plane = Plane(anchor: planeAnchor)
        plane.opacity = showPlanes ? 1 : 0
        
        // store a local reference to the plane
        planes[anchor.identifier] = plane
        
        node.addChildNode(plane)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        if let plane = planes[planeAnchor.identifier] {
            plane.updateWith(anchor: planeAnchor)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        planes.removeValue(forKey: anchor.identifier)
    }
    
}


