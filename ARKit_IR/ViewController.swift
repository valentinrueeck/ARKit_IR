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
    
    @IBAction func resetTrackingButton(_ sender: Any) {
        resetTracking()
    }

    
    var lastNode :SCNNode?
    var lastAnchor: ARImageAnchor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.preferredFramesPerSecond = 60
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
        
        let scene = SCNScene(named: "art.scnassets/infoButton.dae")!
        let infoButton = scene.rootNode.childNode(withName: "Button", recursively: true)!
        infoButton.scale = SCNVector3Make(0.02, 0.02, 0.02)
        infoButton.position = SCNVector3Make(node.position.x ,  0.001 , -Float(referenceImage.physicalSize.height / 2 + CGFloat(infoButton.scale.x / 2)))
        infoButton.eulerAngles.x = .pi / -2
        infoButton.runAction(rotationAction)
        infoButton.name = "infoButton"
        node.addChildNode(infoButton)
        
        if(isAudioSourceAvailable(imageName: referenceImage.name!)){
            let playButton = createAudioButton(imageAnchor: imageAnchor, node: node, sceneName: "playButton.dae", buttonName: "PlayButton")
            node.addChildNode(playButton)
        }

        removeLastAnchorAndNode()
        lastAnchor = imageAnchor
        lastNode = node
    }
    
    //Update AR content
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor){
        
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
        guard let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            fatalError("Missing Assets")
        }
        removeLastAnchorAndNode()
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        configuration.detectionImages = referenceImages
        sceneView.session.run(configuration, options:[.resetTracking, .removeExistingAnchors])
    }
    
    private func removeLastAnchorAndNode(){
        lastNode?.removeFromParentNode()
        if(lastAnchor != nil) {
            sceneView.session.remove(anchor: lastAnchor!)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        if(touch.view == self.sceneView){
            print("Touch working")
            let viewTouchLocation:CGPoint = touch.location(in: sceneView)
            guard let result = sceneView.hitTest(viewTouchLocation, options: [.boundingBoxOnly: true]).first else {
                return
            }
            if(result.node.name == "closeButton"){
                print("Touched closeButton")
                lastNode!.childNode(withName: "infoPlaneNode", recursively: true)?.removeFromParentNode()
            }
            if(result.node.name == "descriptionNode"){
                print("Touched descriptionNode")
            }
            if(result.node.parent?.name == "infoButton"){
                print("Touched infoButtonNode")
                if(lastNode!.childNode(withName: "descriptionNode", recursively: false) != nil){
                    return
                }
                let nodes = createDescriptionPlane(lastAnchor: lastAnchor!, lastNode: lastNode!)
                lastNode!.addChildNode(nodes)
            }
            if(result.node.parent?.name == "PlayButton"){
                print("Touched PlayButton")
                let playButtonNode = result.node.parent
                let audioPlayer = SCNAudioPlayer(source: getAudioSource(imageName: lastAnchor!.referenceImage.name!)!)
                let pauseButton = createAudioButton(imageAnchor: lastAnchor!, node: lastNode!, sceneName: "pauseButton.dae", buttonName: "PauseButton")
                lastNode?.replaceChildNode(playButtonNode!, with: pauseButton)
                audioPlayer.didFinishPlayback = {
                    print("Finished Playback")
                    self.lastNode?.replaceChildNode(pauseButton, with: playButtonNode!)
                }
                pauseButton.addAudioPlayer(audioPlayer)
            }
            if(result.node.parent?.name == "PauseButton") {
                print("Touched PauseButton")
                let pauseButton = result.node.parent!
                pauseButton.removeAllAudioPlayers()
                self.lastNode?.replaceChildNode(pauseButton, with: createAudioButton(imageAnchor: self.lastAnchor!, node: self.lastNode!, sceneName: "playButton.dae", buttonName: "PlayButton"))
            }

        }
    }
}
