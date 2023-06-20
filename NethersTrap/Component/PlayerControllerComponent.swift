//
//  PlayerControllerComponent.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 19/06/23.
//

import SpriteKit
import GameplayKit

class PlayerControllerComponent: GKComponent {
    
    var geometryComponent: GeometryComponent? {
        return entity?.component(ofType: GeometryComponent.self)
    }
    
    var characterTexturesGoDown: [SKTexture] = []
    var characterTexturesGoUp: [SKTexture] = []
//    var animationRepeat: SKAction
    
    override init() {
        super.init()
        for i in 0...11 {
            characterTexturesGoDown.append(SKTexture(imageNamed: "Ghost_A_Down__\(i)"))
            characterTexturesGoUp.append(SKTexture(imageNamed: "Ghost_A_Up__\(i)"))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func movement(moveLeft: Bool, moveRight: Bool, moveUp: Bool, moveDown: Bool, dt: TimeInterval, camera: SKCameraNode, speed: CGFloat) {
        if moveLeft {
            geometryComponent?.geometryNode.position.x -= speed * CGFloat(dt)
        }
        
        if moveRight {
            geometryComponent?.geometryNode.position.x += speed * CGFloat(dt)
        }
        
        if moveDown {
            let animation = SKAction.animate(with: characterTexturesGoDown, timePerFrame: 0.1)
//            let animationRepeat = SKAction.repeatForever(animation)
//            print(animationRepeat)
            geometryComponent?.geometryNode.run(animation)
            geometryComponent?.geometryNode.position.y -= speed * CGFloat(dt)
        }
        
        if moveUp {
//            let animation = SKAction.animate(with: characterTexturesGoUp, timePerFrame: 0.1)
//            let animationRepeat = SKAction.repeatForever(animation)
//            geometryComponent?.geometryNode.run(animationRepeat)
            geometryComponent?.geometryNode.position.y += speed * CGFloat(dt)
        }
        
        camera.position = geometryComponent?.geometryNode.position ?? CGPoint(x: 0.0, y: 0.0)
    }
    
//    func animationMovement(moveLeft: Bool, moveRight: Bool, moveUp: Bool, moveDown: Bool) {
//        if moveLeft {
//
//        }
//
//        if moveRight {
//
//        }
//
//        if moveDown {
//            let animation = SKAction.animate(with: characterTexturesGoDown, timePerFrame: 0.1)
//            let animationRepeat = SKAction.repeatForever(animation)
//            print(animationRepeat)
//            geometryComponent?.geometryNode.run(animationRepeat)
//        }
//
//        if moveUp {
//            let animation = SKAction.animate(with: characterTexturesGoUp, timePerFrame: 0.1)
//            let animationRepeat = SKAction.repeatForever(animation)
//            geometryComponent?.geometryNode.run(animationRepeat)
//        }
//    }
}
