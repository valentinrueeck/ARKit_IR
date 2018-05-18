//
//  AudioController.swift
//  ARKit_IR
//
//  Created by Valentin Rüeck on 18.05.18.
//  Copyright © 2018 Valentin Rüeck. All rights reserved.
//

import Foundation
import SceneKit

func getAudioSource(name: String) -> SCNAudioSource? {
    let audioSource = SCNAudioSource(fileNamed: name)!
    audioSource.load()
    return audioSource
}
