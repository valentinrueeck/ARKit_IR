//
//  AudioController.swift
//  ARKit_IR
//
//  Created by Valentin Rüeck on 18.05.18.
//  Copyright © 2018 Valentin Rüeck. All rights reserved.
//

import Foundation
import SceneKit
import AVKit

func getAudioSource(imageName: String) -> SCNAudioSource? {
    let audioSource = SCNAudioSource(fileNamed: imageName  + "_Audio.mp3")!
    audioSource.load()
    return audioSource
}

func isAudioSourceAvailable(imageName: String) -> Bool {
    let path = Bundle.main.path(forResource: "\(imageName)_Audio.mp3", ofType: nil)!
    return FileManager.default.fileExists(atPath: path)
}

