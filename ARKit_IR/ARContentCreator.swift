//
//  ARContentCreator.swift
//  Image Recognition
//
//  Created by Valentin Rüeck on 15.05.18.
//  Copyright © 2018 Valentin Rüeck. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

public func setTextView(image: ARReferenceImage) -> SKView {
    let skView = SKView(frame: CGRect(x: 0, y: 0, width: 600, height: 500))
    skView.backgroundColor = .white
    
    let attributedString = NSMutableAttributedString(string: image.name!)
    attributedString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: NSRange(location: 0, length: attributedString.length))
    
    let headline = UILabel.init(frame: CGRect(x: 0, y: 0, width: 600, height: 100))
    headline.attributedText = attributedString
    headline.textColor = .black
    headline.backgroundColor = .white
    headline.font = UIFont.boldSystemFont(ofSize: 40)
    
    let textView = UITextView.init(frame: CGRect(x: 0, y: 100, width: 600, height: 400))
    textView.text = "\n" + retrieveDescriptionText(name: image.name!)
    textView.textColor = .black
    textView.backgroundColor = .white
    textView.isEditable = false
    textView.font = UIFont(name: "AmericanTypewriter", size: 20)
    
    skView.addSubview(headline)
    skView.addSubview(textView)

    return skView
}

public func createDescriptionPlane(lastAnchor: ARImageAnchor, lastNode: SCNNode) -> SCNNode {
    let infoPlaneNode = SCNNode()
    infoPlaneNode.name = "infoPlaneNode"
    let descriptionPlane = SCNPlane(width: lastAnchor.referenceImage.physicalSize.width, height: 0.10)
    descriptionPlane.firstMaterial?.diffuse.contents = setTextView(image: lastAnchor.referenceImage)
    descriptionPlane.firstMaterial?.isDoubleSided = true
    let descriptionNode = SCNNode(geometry: descriptionPlane)
    descriptionNode.position = SCNVector3Make(0,-0.05,Float(lastAnchor.referenceImage.physicalSize.height))
    descriptionNode.eulerAngles.x = .pi / -2
    descriptionNode.name = "descriptionNode"
    descriptionPlane.cornerRadius = 0.01
    
    let closeButton = SCNPlane(width: 0.02, height: 0.02)
    closeButton.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "close-window")
    closeButton.firstMaterial?.isDoubleSided = true
    let closeButtonNode = SCNNode(geometry: closeButton)
    closeButtonNode.name = "closeButton"
    closeButtonNode.eulerAngles.x = .pi / -2
//    closeButtonNode.position = SCNVector3Make(Float(descriptionPlane.width / 2 - 0.015), descriptionNode.position.y + 0.001, Float(descriptionPlane.height / 2 + 0.055))

    closeButtonNode.position = SCNVector3Make(Float(descriptionPlane.width / 2), descriptionNode.position.y + 0.001, Float(descriptionPlane.height))
    print("closeButtonPosition: \(closeButtonNode.position)")
    
    print("HEIGHT: \(descriptionPlane.height)")
    
    infoPlaneNode.addChildNode(closeButtonNode)
    infoPlaneNode.addChildNode(descriptionNode)
    return infoPlaneNode    
}

public func createWebview(name: ARReferenceImage) -> SCNNode {
    let plane = SCNPlane(width: 0.5, height: 0.5)
    let webView = UIWebView.init(frame: CGRect(x: 0, y: 0, width: 700, height: 700))
    webView.loadRequest(URLRequest(url: URL(string: "https://google.de")!))
    webView.allowsInlineMediaPlayback = true
    plane.firstMaterial?.diffuse.contents = webView
    plane.firstMaterial?.isDoubleSided = true
    let webViewNode = SCNNode(geometry: plane)
    webViewNode.eulerAngles.x = .pi / -2
    webViewNode.name = "webViewNode"
    return webViewNode
}

public func createAudioButton(imageAnchor: ARImageAnchor, node: SCNNode, sceneName: String, buttonName: String) -> SCNNode {
    let scene = SCNScene(named: "art.scnassets/\(sceneName)")!
    let button = scene.rootNode.childNode(withName: "\(buttonName)", recursively: true)!
    button.name = "\(buttonName)"
    button.eulerAngles.y = .pi / -2
    button.scale = SCNVector3Make(0.02, 0.02, 0.02)
    button.position = SCNVector3Make(node.parent!.position.x + Float(imageAnchor.referenceImage.physicalSize.width / 2 + CGFloat(button.scale.x + 0.01)), node.parent!.position.y, node.parent!.position.z)
    return button
}
