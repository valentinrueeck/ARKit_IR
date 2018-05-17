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

public func createTextSprite(image: ARReferenceImage) -> SKScene {
    let skScene = SKScene(size: CGSize(width: 500, height: 300))
    let rectangle = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 500, height: 300), cornerRadius: 10)
    rectangle.fillColor = .white
    rectangle.strokeColor = #colorLiteral(red: 0, green: 0.01040430573, blue: 0.04792746114, alpha: 1)
    rectangle.lineWidth = 5
    
    let headlineRectangle = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 500, height: 150), cornerRadius: 10)
    headlineRectangle.fillColor = .white
    headlineRectangle.strokeColor = .black
    headlineRectangle.lineWidth = 5
    
    let textNode = SKLabelNode(text: retrieveDescriptionText(name: image.name!))
    textNode.preferredMaxLayoutWidth = 400
    textNode.lineBreakMode = .byWordWrapping
    textNode.numberOfLines = textNode.text!.count / 50
    textNode.fontSize = 20
    textNode.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    textNode.fontName = "AmericanTypewriter"
    textNode.verticalAlignmentMode = .top
    textNode.horizontalAlignmentMode = .left
    textNode.position = CGPoint(x: 20, y: 300)
    
    let headlineNode = SKLabelNode(text: image.name!)
    headlineNode.fontSize = 30
    headlineNode.horizontalAlignmentMode = .center
    headlineNode.fontColor = .black
    headlineNode.fontName = "AmericanTypewriter"
    headlineNode.position = CGPoint(x: 100, y: 220)
    
    rectangle.addChild(textNode)
    headlineRectangle.addChild(headlineNode)
    
    skScene.addChild(headlineRectangle)
    skScene.addChild(rectangle)
    return skScene
}

public func setText(image: ARReferenceImage) -> SCNText {
    let material = SCNMaterial()
    material.diffuse.contents = UIColor.white
    let text =  SCNText(string: retrieveDescriptionText(name: image.name!), extrusionDepth: 1)
    text.font = UIFont(name: "Helvetica", size: 20)
    text.containerFrame = CGRect(origin: .zero, size: CGSize(width: 100.0, height: 500.0))
    text.isWrapped = true
    text.materials = [material]
    return text
}

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
    print("TEXT: \(textView.text)")
    textView.textColor = .black
    textView.backgroundColor = .white
    textView.isEditable = false
    textView.font = UIFont(name: "AmericanTypewriter", size: 20)
    
    skView.addSubview(headline)
    skView.addSubview(textView)
    print("SUBVIEWS: \(skView.subviews.count)")

    return skView
}

public func createDescriptionPlane(lastAnchor: ARImageAnchor, lastNode: SCNNode) -> (SCNNode, SCNNode) {
    let descriptionPlane = SCNPlane(width: lastAnchor.referenceImage.physicalSize.width, height: 0.10)
    //descriptionPlane.firstMaterial?.diffuse.contents = createTextSprite(image: lastAnchor!.referenceImage)
    descriptionPlane.firstMaterial?.diffuse.contents = setTextView(image: lastAnchor.referenceImage)
    descriptionPlane.firstMaterial?.isDoubleSided = true
    print("\(String(describing: descriptionPlane.firstMaterial?.diffuse.contents.debugDescription))")
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
    closeButtonNode.position = SCNVector3Make(Float(descriptionPlane.width / 2 - 0.015), descriptionNode.position.y + 0.001, Float(descriptionPlane.height / 2 + 0.055))
    
    return (closeButtonNode, descriptionNode)
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
