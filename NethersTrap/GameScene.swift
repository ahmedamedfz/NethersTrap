//
//  GameScene.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 16/06/23.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var characterEntities = [CharEntity]()
//    var TriggerEntities = [GKEntity]()
    var TriggerEntities = [TriggerEntity]()
    var cameraNode: SKCameraNode!
//    var triggerLamp: SKSpriteNode!
    
//    static public var instance: GameScene = GameScene()
    private var lastUpdateTime : TimeInterval = 0
//    private var label : SKLabelNode?
//    private var spinnyNode : SKShapeNode?
    
    
    let playerControlComponentSystem = GKComponentSystem(componentClass: PlayerControllerComponent.self)
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        setupEntities()
        addComponentsToComponentSystems()
    }
    
    func setupEntities() {
        let playerEntity = CharEntity(name: "GhostADown/0", role: .Player)
        addChild(playerEntity.objCharacter)
        
        let enemyEntity = CharEntity(name: "GhostADown/5", role: .Enemy)
        addChild(enemyEntity.objCharacter)
//        let switchEntity = makeSwitch()
        let switchEntity = TriggerEntity(name: "Cobblestone_Grid_Center", type: .Switch)
        addChild(switchEntity.objTrigger)
        
        let hideOutEntity = TriggerEntity(name: "Water_Grid_Center", type: .HideOut)
        addChild(hideOutEntity.objTrigger)
        characterEntities = [enemyEntity, playerEntity]
        TriggerEntities = [switchEntity]
        makeCamera()
    }
    
    func makeCamera() {
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
        
    }
    
    func addComponentsToComponentSystems() {
        for ent in characterEntities {
            playerControlComponentSystem.addComponent(foundIn: ent)
        }
        
    }
    
//    aa
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision:UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        
        if characterEntities[1].objCharacter.hit.isEmpty {
            if collision == 0x10 | 0x100 {
                print("yes")
                characterEntities[1].objCharacter.hit = "Switch"
                characterEntities[1].objCharacter.isHidden = true
            } else if collision == 0x10 | 0x1000 && !characterEntities[1].objCharacter.deathAnimating {
                print("Catched")
                characterEntities[1].objCharacter.hit = "Catched"
                characterEntities[1].objCharacter.deathAnimating = true
//                animateDeath()
                for case let component as PlayerControllerComponent in playerControlComponentSystem.components {
                    component.animateDeath()
                }
                
            } else if collision == 0x10 | 0x10000 {
                print("hide")
                characterEntities[1].objCharacter.hidingRange = true
            }
        }
        
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        characterEntities[1].objCharacter.hit = ""
        characterEntities[1].objCharacter.isHidden = false
        characterEntities[1].objCharacter.hidingRange = false
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0:
            characterEntities[1].objCharacter.left = true
        case 2:
            characterEntities[1].objCharacter.right = true
        case 1:
            characterEntities[1].objCharacter.down = true
        case 13:
            characterEntities[1].objCharacter.up = true
        case 3:
            if characterEntities[1].objCharacter.hidingRange {
                characterEntities[1].objCharacter.isHidden = true
                characterEntities[1].objCharacter.isMovement = false
                run(SKAction.repeat(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.run(startCountDown)]), count: 5)) {
                    self.characterEntities[1].objCharacter.timeHiding = 5
                }
//                CharacterEntities[1].objCharacter.hidingRange = false
            } else {
                characterEntities[1].objCharacter.isHidden = false
                characterEntities[1].objCharacter.isMovement = true
            }
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    func startCountDown() {
        for case let component as PlayerControllerComponent in playerControlComponentSystem.components {
            component.countDown()
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 0:
            characterEntities[1].objCharacter.left = false
        case 2:
            characterEntities[1].objCharacter.right = false
        case 1:
            characterEntities[1].objCharacter.down = false
        case 13:
            characterEntities[1].objCharacter.up = false
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        for case let component as PlayerControllerComponent in playerControlComponentSystem.components {
            component.movement(moveLeft: characterEntities[1].objCharacter.left, moveRight: characterEntities[1].objCharacter.right, moveUp: characterEntities[1].objCharacter.up, moveDown: characterEntities[1].objCharacter.down, dt: dt, camera: cameraNode, speed: characterEntities[1].objCharacter.walkSpeed, isMovement: characterEntities[1].objCharacter.isMovement)
        }
        
        self.lastUpdateTime = currentTime
    }
}
