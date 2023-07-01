//
//  PlayerControllerComponent.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 19/06/23.
//

import SpriteKit
import GameplayKit

class PlayerControllerComponent: GKComponent {
    
    var geometryComponent: GeometryComponent<PlayerEntity>? {
        return entity?.component(ofType: GeometryComponent.self)
    }
    var characterDownTexture: [SKTexture] = []
    var characterDown: SKAction = SKAction()
    var characterUpTexture: [SKTexture] = []
    var characterUp: SKAction = SKAction()
    var characterRightTexture: [SKTexture] = []
    var characterRight: SKAction = SKAction()
    var characterLeftTexture: [SKTexture] = []
    var characterLeft: SKAction = SKAction()
    
    var lastMovement: lastMove = .none
    
    override init() {
        super.init()
        for i in 0...11 {
            characterDownTexture.append(SKTexture(imageNamed: "GhostADown/\(i)"))
            characterUpTexture.append(SKTexture(imageNamed: "GhostAUp/\(i)"))
            characterLeftTexture.append(SKTexture(imageNamed: "GhostALeft/\(i)"))
            characterRightTexture.append(SKTexture(imageNamed: "GhostARight/\(i)"))
        }
        characterDown = SKAction.animate(with: characterDownTexture, timePerFrame: 0.1)
        characterUp = SKAction.animate(with: characterUpTexture, timePerFrame: 0.1)
        characterRight = SKAction.animate(with: characterRightTexture, timePerFrame: 0.1)
        characterLeft = SKAction.animate(with: characterLeftTexture, timePerFrame: 0.1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func movement(dt: TimeInterval, camera: SKCameraNode) {
        if geometryComponent?.geometryNode.objCharacter.isMovement ?? true {
            if (geometryComponent?.geometryNode.objCharacter.right ?? false && geometryComponent?.geometryNode.objCharacter.down ?? false) {
                geometryComponent?.geometryNode.objCharacter.position.y -= geometryComponent?.geometryNode.objCharacter.speed ?? 40.0 * CGFloat(dt)
            } else if (geometryComponent?.geometryNode.objCharacter.left ?? false && geometryComponent?.geometryNode.objCharacter.down ?? false) {
                geometryComponent?.geometryNode.objCharacter.position.y -= geometryComponent?.geometryNode.objCharacter.speed ?? 40.0 * CGFloat(dt)
            }else if geometryComponent?.geometryNode.objCharacter.down ?? false && geometryComponent?.geometryNode.objCharacter.up ?? false {
                if lastMovement == .down {
                    geometryComponent?.geometryNode.objCharacter.position.y -= geometryComponent?.geometryNode.objCharacter.speed ?? 40.0 * CGFloat(dt)
                    animateMove(arrowPress: .down, movement: characterDown)
                    lastMovement = .down
                } else if lastMovement == .up {
                    geometryComponent?.geometryNode.objCharacter.position.y += geometryComponent?.geometryNode.objCharacter.speed ?? 40.0 * CGFloat(dt)
                    animateMove(arrowPress: .up, movement: characterUp)
                    lastMovement = .up
                }
                
            } else if (geometryComponent?.geometryNode.objCharacter.right ?? false && geometryComponent?.geometryNode.objCharacter.up ?? false) {
                geometryComponent?.geometryNode.objCharacter.position.y += geometryComponent?.geometryNode.objCharacter.speed ?? 40.0 * CGFloat(dt)
            } else if (geometryComponent?.geometryNode.objCharacter.left ?? false && geometryComponent?.geometryNode.objCharacter.up ?? false) {
                geometryComponent?.geometryNode.objCharacter.position.y += geometryComponent?.geometryNode.objCharacter.speed ?? 40.0 * CGFloat(dt)
            } else if geometryComponent?.geometryNode.objCharacter.down ?? false {
                geometryComponent?.geometryNode.objCharacter.position.y -= geometryComponent?.geometryNode.objCharacter.speed ?? 40.0 * CGFloat(dt)
                animateMove(arrowPress: .down, movement: characterDown)
                lastMovement = .down
            } else if geometryComponent?.geometryNode.objCharacter.up ?? false {
                geometryComponent?.geometryNode.objCharacter.position.y += geometryComponent?.geometryNode.objCharacter.speed ?? 40.0 * CGFloat(dt)
                animateMove(arrowPress: .up, movement: characterUp)
                lastMovement = .up
            }
            
            if geometryComponent?.geometryNode.objCharacter.left ?? false && geometryComponent?.geometryNode.objCharacter.right ?? false {
                if lastMovement == .left {
                    geometryComponent?.geometryNode.objCharacter.position.x -= geometryComponent?.geometryNode.objCharacter.speed ?? 40.0 * CGFloat(dt)
                    animateMove(arrowPress: .left, movement: characterLeft)
                    lastMovement = .left
                } else if lastMovement == .right {
                    geometryComponent?.geometryNode.objCharacter.position.x += geometryComponent?.geometryNode.objCharacter.speed ?? 40.0 * CGFloat(dt)
                    animateMove(arrowPress: .right, movement: characterRight)
                    lastMovement = .right
                }
            } else if geometryComponent?.geometryNode.objCharacter.left ?? false {
                geometryComponent?.geometryNode.objCharacter.position.x -= geometryComponent?.geometryNode.objCharacter.speed ?? 40.0 * CGFloat(dt)
                animateMove(arrowPress: .left, movement: characterLeft)
                lastMovement = .left
            } else if geometryComponent?.geometryNode.objCharacter.right ?? false {
                geometryComponent?.geometryNode.objCharacter.position.x += geometryComponent?.geometryNode.objCharacter.speed ?? 40.0 * CGFloat(dt)
                animateMove(arrowPress: .right, movement: characterRight)
                lastMovement = .right
            }
        }
//        camera.position = geometryComponent?.geometryNode.objCharacter.position ?? CGPoint(x: 0.0, y: 0.0)
    }
    
    func animateDeath() {
        geometryComponent?.geometryNode.objCharacter.run(SKAction.wait(forDuration: 5)) {
            self.geometryComponent?.geometryNode.objCharacter.deathAnimating = false
            print("Animation done")
        }
    }

    func animateMove(arrowPress: lastMove, movement: SKAction) {
        if arrowPress != lastMovement {
            geometryComponent?.geometryNode.objCharacter.run(SKAction.repeatForever(movement))
//            print("Ubah Arah")
        }
    }
    
    func countDown() {
        geometryComponent?.geometryNode.objCharacter.timeHiding -= 1
        if (geometryComponent?.geometryNode.objCharacter.timeHiding == 0){
            geometryComponent?.geometryNode.objCharacter.hidingRange = false
            unHide()
        }
    }
    
    func unHide() {
        geometryComponent?.geometryNode.objCharacter.isMovement = true
        geometryComponent?.geometryNode.objCharacter.isHidden = false
        geometryComponent?.geometryNode.objCharacter.timeHiding = 5
//        print("Out")
    }
}

enum lastMove {
    case left, right, down, up, none
}
