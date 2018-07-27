//
//  ViewController.swift
//  MeasureMove
//
//  Created by Ahmed Nimra on 27.06.18.
//  Copyright © 2018 Ahmed Nimra. All rights reserved.
//



import UIKit
import SceneKit
import ARKit

final class ViewController: UIViewController {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var targetImageView: UIImageView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var resetButton: UIButton!
    
    fileprivate lazy var session = ARSession()
    fileprivate lazy var posZ = Float()
    fileprivate lazy var sessionConfiguration = ARWorldTrackingConfiguration()
    fileprivate lazy var isMeasuring = false;
    fileprivate lazy var vectorZero = SCNVector3()
    fileprivate lazy var startValue = SCNVector3()
    fileprivate lazy var endValue = SCNVector3()
    fileprivate lazy var lines: [Line] = []
    fileprivate var currentLine: Line?
    fileprivate lazy var unit: DistanceUnit = .centimeter
    
    private var planes = [UUID: Plane]()
    let sceneManager = ARSceneManager()
    
    override func viewDidLoad() {
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        super.viewDidLoad()
        setupScene() //

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        sceneView.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer)
    {
        isMeasuring = false
        targetImageView.image = UIImage(named: "targetWhite")
        currentLine?.removeFromParentNode()
    }

    @objc func handleTap(sender: UITapGestureRecognizer){
        let touchPosition = sender.location(in: sceneView)
        
        // Translate those 2D points to 3D points using hitTest (existing plane)
        let hitTestResults = sceneView.hitTest(touchPosition, types: .existingPlaneUsingExtent)
        }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetValues()
        isMeasuring = true
        targetImageView.image = UIImage(named: "targetGreen")
    }
    @IBAction func resetButtonTapped(button: UIButton) {
        print(lines.count)
        for line in lines {
            line.removeFromParentNode()
        }
        currentLine?.removeFromParentNode()
    }
}

// WHy is this needed? Copy pasted from internet? Otherwise infinitely loads

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            self?.detectObjects()
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        messageLabel.text = "Error occurred"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        messageLabel.text = "Interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        messageLabel.text = "Interruption ended"
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // we only care about planes
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let plane = Plane(anchor: planeAnchor)
        plane.opacity = 1
        // store a local reference to the plane
        planes[anchor.identifier] = plane
        print("Found plane: \(anchor)")
        node.addChildNode(plane)
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        if let plane = planes[planeAnchor.identifier] {
            plane.updateWith(anchor: planeAnchor)
        }
    }
    
    @IBAction func showPlanes(_ sender: Any) {
        sceneManager.showPlanes = true

        planes.values.forEach {
            $0.runAction(SCNAction.fadeIn(duration: 0.5))}
    }
    @IBAction func hidePlanes(_ sender: Any){
        sceneManager.showPlanes = false
        planes.values.forEach {
            $0.runAction(SCNAction.fadeOut(duration: 0.5))
        }
    }
}

extension ViewController {
    fileprivate func setupScene() {
        targetImageView.isHidden = true
        sceneView.delegate = self
        sceneView.session = session
        loadingView.startAnimating()
        messageLabel.text = "Setting up the wooorld :D"
        resetButton.isHidden = true
        startPlaneDetection()
     
        resetValues()
    }
    
    func startPlaneDetection() {
        sessionConfiguration.planeDetection = [.horizontal, .vertical]
        sessionConfiguration.isLightEstimationEnabled = true
        sceneView?.session.run(sessionConfiguration)
    }
    
    fileprivate func resetValues() {
        isMeasuring = false
        startValue = SCNVector3()
        endValue =  SCNVector3()
    }
    
    fileprivate func detectObjects() {
        guard let Position = sceneView.realWorldVector(screenPosition: view.center) else { return }
        
        let planeAnchor = Position.anchor as? ARPlaneAnchor
        
    
        
        let worldPosition = SCNVector3.positionFromTransform(Position.worldTransform)
     
        
        targetImageView.isHidden = false
        if lines.isEmpty {
            messageLabel.text = "Keep holding it & move :D "
            resetButton.isHidden = false
        }
        loadingView.stopAnimating()
        if isMeasuring {
            if startValue == vectorZero {
                startValue = worldPosition
                currentLine = Line(sceneView: sceneView, startVector: startValue, unit: unit)
            }
            endValue = worldPosition // not world position, second tap
            currentLine?.update(to: endValue)
            lines.append(currentLine!)
          
        
            messageLabel.text = currentLine?.distance(to: endValue) ?? "Let me think..."
        }
    }
}
