//
//  ViewController.swift
//  NethersTrap
//
//  Created by Ahmad Fariz on 16/06/23.
//

import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = CutScene(fileNamed: "CutScene")
                //, let graphic = GKScene(fileNamed: "MenuScene")
            {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                //scene.wanderGraph = graphic.graphs["WanderGraph"]?.nodes as? [GKGraphNode2D]
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
}

