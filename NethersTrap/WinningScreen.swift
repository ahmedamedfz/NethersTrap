//
//  WinningScreen.swift
//  NethersTrap
//
//  Created by Aditya Mario Tanuhardja on 01/07/23.
//

import SpriteKit
import GameplayKit

class WinningScreen: SKScene {
    
    
    let returnButton = SKSpriteNode(imageNamed: "returnButton")
    let successText = SKSpriteNode(imageNamed: "successEscape")
    

    
    override func didMove(to view: SKView) {
        
        
        setupReturnButton()
        successEscape()

    }
    
    func successEscape(){
        successText.size = CGSize(width: 327, height: 72)
        successText.position = CGPoint(x: frame.midX, y: frame.midY+180)
        successText.name = "successText"
        successText.zPosition = 2
        addChild(successText)
    }
    
   
    func setupReturnButton() {
      
        returnButton.size = CGSize(width: 238, height: 38)
        returnButton.position = CGPoint(x: frame.midX, y: frame.midY-180)
        returnButton.name = "returnButton"
        returnButton.zPosition = 2
        addChild(returnButton)
        
    }
    
    override func mouseDown(with event: NSEvent) {
            let location = event.location(in: self)
            let nodes = nodes(at: location)

            for node in nodes {
                if node.name == "playButton" {
                    returnButton.isHidden = true
                    // Perform the desired action when the button is pressed
                    // For example, transition to a new scene or start the game
                    // Your code here...
                    
                    // Create and configure the new game scene
//                        let newScene = AnotherScene(size: self.size)
//                        newScene.scaleMode = self.scaleMode
//                        let transition = SKTransition.doorsCloseHorizontal(withDuration: 2) //
//                        self.view?.presentScene(newScene, transition: transition)
//
                    
                    break
                }
            }
        }
    
    
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
