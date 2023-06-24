//
//  Entity.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 20/06/23.
//

import Foundation
import GameplayKit
import SpriteKit

class CharEntity: GKEntity, GKAgentDelegate {
    let nameEntity: String
    var role: Role
    var objCharacter: CharacterNode
    var texture: SKTexture
    
    var agent = GKAgent2D()
    
    init(name: String, role: Role, spriteImage: String) {
        nameEntity = name
        self.role = role
        texture = SKTexture(imageNamed: spriteImage)
        objCharacter = CharacterNode(texture: texture)
        super.init()
        makeEntities()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeEntities() {
        objCharacter.speed = 1.0
        objCharacter.zPosition = 100
        objCharacter.physicsBody = SKPhysicsBody(texture: texture, size: self.objCharacter.size)
        objCharacter.setScale(0.4)
        objCharacter.physicsBody?.isDynamic = true
        objCharacter.physicsBody?.affectedByGravity = false
        objCharacter.physicsBody?.allowsRotation = false
        objCharacter.physicsBody?.collisionBitMask = 0x1
        
        if self.role == .Player {
            definePlayer()
        } else if self.role == .Enemy {
            defineEnemy()
        }
        
        let geometryComponent = GeometryComponent<CharacterNode>(geometryNode: self.objCharacter)
        addComponent(geometryComponent)
    }
    
    func definePlayer() {
        
        objCharacter.position = CGPoint(x: 0, y: 0)
        objCharacter.physicsBody?.categoryBitMask = 0x10
        objCharacter.physicsBody?.contactTestBitMask = 0x100 | 0x1000
        
        let playerControllerComponent = PlayerControllerComponent()
        addComponent(playerControllerComponent)
    }
    
    func defineEnemy() {
        objCharacter.position = CGPoint(x: 50, y: 0)
        objCharacter.physicsBody?.categoryBitMask = 0x1000
        objCharacter.physicsBody?.contactTestBitMask = 0x10
        
        let geometryComponent = GeometryComponent(geometryNode: objCharacter)
        addComponent(geometryComponent)
    }
    
    func agentWillUpdate(_ agent: GKAgent) {
        if let agent2D = agent as? GKAgent2D {
            agent2D.position = SIMD2(Float(objCharacter.position.x), Float(objCharacter.position.y))
        }
    }
    
    func agentDidUpdate(_ agent: GKAgent) {
        if let agent2D = agent as? GKAgent2D {
            objCharacter.position = CGPoint(x: CGFloat(agent2D.position.x), y: CGFloat(agent2D.position.y))
        }
    }
}

enum Role {
    case Player, Enemy
}
