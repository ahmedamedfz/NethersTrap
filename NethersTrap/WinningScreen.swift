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
    let backgroundImg = SKSpriteNode(imageNamed: "Winning screen")
    
    
    override func didMove(to view: SKView) {
        
        setBackground()
        setupReturnButton()
        successEscape()
        
    }
    func setBackground() {
        backgroundImg.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundImg.size = CGSize(width: 1468.45, height: 1055.8)
        backgroundImg.zPosition = 1
        addChild(backgroundImg)
    }
    
    func successEscape(){
        successText.size = CGSize(width: 654, height: 144)
        successText.position = CGPoint(x: frame.midX, y: frame.midY+180)
        successText.name = "successText"
        successText.zPosition = 2
        addChild(successText)
    }
    
    
    func setupReturnButton() {
        
        returnButton.size = CGSize(width: 476, height: 76)
        returnButton.position = CGPoint(x: frame.midX, y: frame.midY-180)
        returnButton.name = "returnButton"
        returnButton.zPosition = 2
        addChild(returnButton)
        
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let nodes = nodes(at: location)
        
        for node in nodes {
            if node.name == "returnButton" {
//                print(node.name)
                let newScene = MenuScene(fileNamed: "MenuScene")
//                let newScene = MenuScene(size: (view?.bounds.size)!)
                newScene!.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 2)
                self.view?.presentScene(newScene!, transition: transition)
                break
                
//                if let parent = self.parent, parent is SKScene {
//                   let pScene = parent as! SKScene
//                   // do whatever you want with your scene
//                    let newScene = pScene
//                    newScene.size = (view?.bounds.size)!
//                    newScene.scaleMode = self.scaleMode
//                    let transition = SKTransition.fade(withDuration: 2)
//                    self.view?.presentScene(newScene, transition: transition)
//                }
            }
        }
    }
    
    
    
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
