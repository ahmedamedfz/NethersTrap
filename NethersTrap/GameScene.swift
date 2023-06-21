//
//  GameScene.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 16/06/23.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var CharacterEntities = [CharEntity]()
//    var TriggerEntities = [GKEntity]()
    var TriggerEntities = [TriggerEntity]()
    var cameraNode: SKCameraNode!
//    var triggerLamp: SKSpriteNode!
    
    
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
        let switchEntity = TriggerEntity(name: "Cobblestone_Grid_Center", role: .Switch)
        addChild(switchEntity.objTrigger)
        
        CharacterEntities = [playerEntity, enemyEntity]
        TriggerEntities = [switchEntity]
        makeCamera()
    }
    
//    func makeSwitch() -> GKEntity {
//        let swtch = GKEntity()
//        triggerLamp = childNode(withName: "triggerLamp") as? SKSpriteNode
////        print("masuk")
////        print("trigger: \(String(describing: triggerLamp))")
//        triggerLamp.physicsBody?.categoryBitMask = 0x100
//        triggerLamp.physicsBody?.contactTestBitMask = 0x10
//
//        let geometryComponent = GeometryComponent(geometryNode: triggerLamp)
//        swtch.addComponent(geometryComponent)
//
//        return swtch
//    }
    
    func makeCamera() {
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
        
    }
    
    func addComponentsToComponentSystems() {
        for ent in CharacterEntities {
            playerControlComponentSystem.addComponent(foundIn: ent)
        }
        
    }
    
    func animateDeath() {
        CharacterEntities[0].objCharacter.run(SKAction.wait(forDuration: 5)) {
            print("Animation Done")
            self.CharacterEntities[0].objCharacter.deathAnimating = false
            
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision:UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        
        if CharacterEntities[0].objCharacter.hit.isEmpty {
            if collision == 0x10 | 0x100 {
                print("yes")
                CharacterEntities[0].objCharacter.hit = "Switch"
                CharacterEntities[0].objCharacter.isHidden = true
            } else if collision == 0x10 | 0x1000 && !CharacterEntities[0].objCharacter.deathAnimating {
                print("Catched")
                CharacterEntities[0].objCharacter.hit = "Catched"
                CharacterEntities[0].objCharacter.deathAnimating = true
                animateDeath()
//                for case let component as PlayerControllerComponent in playerControlComponentSystem.components {
//                    CharacterEntities[0].objCharacter.deathAnimating = component.animateDeath()
//                }
                
            }
        }
        
        
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        CharacterEntities[0].objCharacter.hit = ""
        CharacterEntities[0].objCharacter.isHidden = false
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123:
            CharacterEntities[0].objCharacter.left = true
        case 124:
            CharacterEntities[0].objCharacter.right = true
        case 125:
            CharacterEntities[0].objCharacter.down = true
        case 126:
            CharacterEntities[0].objCharacter.up = true
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 123:
            CharacterEntities[0].objCharacter.left = false
        case 124:
            CharacterEntities[0].objCharacter.right = false
        case 125:
            CharacterEntities[0].objCharacter.down = false
        case 126:
            CharacterEntities[0].objCharacter.up = false
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
            component.movement(moveLeft: CharacterEntities[0].objCharacter.left, moveRight: CharacterEntities[0].objCharacter.right, moveUp: CharacterEntities[0].objCharacter.up, moveDown: CharacterEntities[0].objCharacter.down, dt: dt, camera: cameraNode, speed: CharacterEntities[0].objCharacter.walkSpeed)
        }
        
        self.lastUpdateTime = currentTime
    }
}
