//
//  GridMaterial.swift
//  MeasureMove
//
//  Created by Ahmed Nimra on 02.07.18.
//  Copyright © 2018 Ahmed Nimra. All rights reserved.
//

import ARKit

class GridMaterial: SCNMaterial {
    
    override init() {
        super.init()
        
        let image = UIImage(named: "DetectedPlanes")?.alpha(0.5)
        diffuse.contents = image
        diffuse.wrapS = .repeat
        diffuse.wrapT = .repeat
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(anchor: ARPlaneAnchor) {
        
        /*
         Scene Kit uses meters for its measurements.
         In order to get the texture looking good we need to decide the amount of times we want it to repeat per meter.
         */
        
        let mmPerMeter: Float = 1000
        let mmOfImage: Float = 65
        let repeatAmount: Float = mmPerMeter / mmOfImage
        
        diffuse.contentsTransform = SCNMatrix4MakeScale(anchor.extent.x * repeatAmount, anchor.extent.z * repeatAmount, 1)
    }
    
}


extension UIImage {
    
    func alpha(_ value:CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
