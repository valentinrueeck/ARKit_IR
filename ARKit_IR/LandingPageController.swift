//
//  LandingPageController.swift
//  ARKit_IR
//
//  Created by Valentin Rüeck on 29.05.18.
//  Copyright © 2018 Valentin Rüeck. All rights reserved.
//

import UIKit

class LandingPageController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButton.layer.cornerRadius = 10
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
