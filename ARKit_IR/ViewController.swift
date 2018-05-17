//
//  ViewController.swift
//  Image Recognition
//
//  Created by Valentin Rüeck on 23.04.18.
//  Copyright © 2018 Valentin Rüeck. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var sessionInfoView: UIView!
    @IBOutlet weak var sessionInfoLabel: UILabel!
    
    var lastNode :SCNNode?
    var lastAnchor: ARImageAnchor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.preferredFramesPerSecond = 30
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("ARKit is not available on this device.")
        }
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing Assets")
        }
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.detectionImages = referenceImages
        
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        sceneView.session.delegate = self
        sceneView.showsStatistics = true
        UIApplication.shared.isIdleTimerDisabled = true

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    //ARSCNViewDelegate    
    //Place AR content
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else {return}
        let referenceImage = imageAnchor.referenceImage
        
        let highlightNode = SCNNode(geometry: SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height))
        highlightNode.eulerAngles.x = .pi / -2
        highlightNode.opacity = 0.25
        node.addChildNode(highlightNode)
        highlightNode.runAction(imageHighlightAction)
        
        let infoButtonShape = SCNPlane(width: 0.05, height: 0.05)
        infoButtonShape.cornerRadius = 1
        infoButtonShape.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "iOSButton")
        infoButtonShape.firstMaterial?.isDoubleSided = true
        let infoButtonNode = SCNNode(geometry: infoButtonShape)
        infoButtonNode.eulerAngles.x = .pi / -2
        infoButtonNode.name = "infoButton"
        infoButtonNode.position = SCNVector3Make(node.position.x ,  0.001 , -Float(referenceImage.physicalSize.height / 2 + infoButtonShape.height / 2))
        node.addChildNode(infoButtonNode)
        infoButtonNode.runAction(rotationAction)
        
        lastNode?.removeFromParentNode()
        if(lastAnchor != nil) {
            sceneView.session.remove(anchor: lastAnchor!)
        }
        lastAnchor = imageAnchor
        lastNode = node
    }
    
    //Update AR content
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor){
//        guard let planeNode = node.childNode(withName: "planeNode", recursively: true) else {return}
//
//        let cameraZ = sceneView.session.currentFrame!.camera.transform.columns.3.z
//        let scaling = 0.2 + (cameraZ * 5)
//        var scale: SCNVector3
////        var position: SCNVector3
//        if(scaling < 0){
//            scale = SCNVector3Make(0.2 ,0.2, planeNode.scale.z)
////            position = SCNVector3Make(node.position.x - 0.25, node.position.y, node.position.z)
//        } else {
//            scale = SCNVector3Make(0.2 + (cameraZ * 5), 0.2 + (cameraZ * 5), planeNode.scale.z)
////            position = SCNVector3Make(node.position.x - ( 0.25 *  (1 + cameraZ)), node.position.y, node.position.z)
//        }
//
//        DispatchQueue.main.async {
//            self.sessionInfoLabel.text = "\(0.2 + cameraZ * 5) \(node.position.x - ( 0.25 *  (1 + cameraZ)))"
//        }
//
//        planeNode.scale = scale
////        planeNode.position = position
//        print("ANCHORS IN SCENE: \(sceneView.session.currentFrame!.anchors.count)")
//        print("NODES IN SCENE: \(sceneView.scene.rootNode.childNodes.count)")
        DispatchQueue.main.async {
            self.sessionInfoLabel.text = "ANCHORS: \(self.sceneView.session.currentFrame!.anchors.count) NODES: \(self.sceneView.scene.rootNode.childNodes.count)"
        }
        
    }

    //ARSession Delegate
    
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        guard let frame = session.currentFrame else {return}
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, didRemove anchors: [ARAnchor]){
        guard let frame = session.currentFrame else {return}
        updateSessionInfoLabel(for: frame, trackingState: frame.camera.trackingState)
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        updateSessionInfoLabel(for: session.currentFrame!, trackingState: camera.trackingState)
    }
   
    //ARSessionObserver
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        sessionInfoLabel.text = "Session Error: \(error.localizedDescription)"
        resetTracking()
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        sessionInfoLabel.text = "Session was interrupted"

    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        sessionInfoLabel.text = "Interruption ended"
        resetTracking()
    }
    
    private func updateSessionInfoLabel(for frame: ARFrame, trackingState: ARCamera.TrackingState) {
//        let message: String
//
//        switch trackingState {
//        case .normal where frame.anchors.isEmpty:
//            message = "Move the device around to detect horizontal surfaces."
//
//        case .notAvailable:
//            message = "Tracking unavailable."
//
//        case .limited(.excessiveMotion):
//            message = "Tracking limited - Move the device more slowly."
//
//        case .limited(.insufficientFeatures):
//            message = "Tracking limited - Point the device at an area with visible surface detail, or improve lighting conditions."
//
//        case .limited(.initializing):
//            message = "Initializing AR session."
//
//        default:
//            message = ""
//        }
//
//        sessionInfoLabel.text = message
//        sessionInfoView.isHidden = message.isEmpty
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
            ])
    }
    
    var rotationAction: SCNAction {
        return .sequence([
            .moveBy(x: 0.0, y: 0.0, z: -0.05, duration: 0.25),
            .rotateBy(x: 0, y: .pi * 2, z: .pi * 2, duration: 0.75),
            .moveBy(x: 0.0, y: 0.0, z: 0.05, duration: 0.25)
            ])
    }
    
    private func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration, options:[.resetTracking, .removeExistingAnchors])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if(touch.view == self.sceneView){
            print("Touch working")
            let viewTouchLocation:CGPoint = touch.location(in: sceneView)
            guard let result = sceneView.hitTest(viewTouchLocation, options: nil).first else {
                return
            }
            if(result.node.name == "infoButton"){
                print("Touched infoButtonNode")
                if(lastNode!.childNode(withName: "descriptionNode", recursively: false) != nil){
                    return
                }
                let nodes = createDescriptionPlane(lastAnchor: lastAnchor!, lastNode: lastNode!)
                lastNode!.addChildNode(nodes.0)
                lastNode!.addChildNode(nodes.1)
//                lastNode!.childNode(withName: "infoButton", recursively: false)?.removeFromParentNode()
            }
            if(result.node.name == "closeButton"){
                print("Touched closeButton")
                lastNode!.childNode(withName: "closeButton", recursively: false)?.removeFromParentNode()
                lastNode!.childNode(withName: "descriptionNode", recursively: false)?.removeFromParentNode()
            }
            if(result.node.name == "descriptionNode"){
                print("Touched descriptionNode")
//                lastNode!.replaceChildNode(lastNode!.childNode(withName: "descriptionNode", recursively: false)!, with: createWebview(name: lastAnchor!.referenceImage))
            }
        }
    }
}