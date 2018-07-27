//
//  ARSCNView.swift
//  MeasureMove
//
//  Created by Ahmed Nimra on 27.06.18.
//  Copyright © 2018 Ahmed Nimra. All rights reserved.
//

import SceneKit
import ARKit

extension ARSCNView {


    func realWorldVector(screenPosition: CGPoint) -> ARHitTestResult? {
        let results = self.hitTest(screenPosition, types: [.existingPlaneUsingGeometry])
        guard let result = results.first else { return nil }
        return result
    }
}
