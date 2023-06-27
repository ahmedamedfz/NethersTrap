//
//  Entity.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 20/06/23.
//

import Foundation
import GameplayKit
import SpriteKit

class PlayerEntity: GKEntity, GKAgentDelegate {
    let nameEntity: String
    let role: String
    let objCharacter: PlayerNode
    let texture: SKTexture
    
    var agent = GKAgent2D()
    
    init(name: String, role: String, spriteImage: String) {
        nameEntity = name
        self.role = role
        texture = SKTexture(imageNamed: spriteImage)
        objCharacter = PlayerNode(texture: texture)
        super.init()
        makePlayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makePlayer() {
        objCharacter.speed = 2.0
        objCharacter.zPosition = 100
        objCharacter.physicsBody = SKPhysicsBody(texture: texture, size: self.objCharacter.size)
        objCharacter.setScale(1)
        objCharacter.physicsBody?.isDynamic = true
        objCharacter.physicsBody?.affectedByGravity = false
        objCharacter.physicsBody?.allowsRotation = false
        objCharacter.physicsBody?.collisionBitMask = 0x1
        objCharacter.position = CGPoint(x: 0, y: 0)
        objCharacter.physicsBody?.categoryBitMask = 0x10
        objCharacter.physicsBody?.contactTestBitMask = 0x100 | 0x1000
        
        let playerControllerComponent = PlayerControllerComponent()
        addComponent(playerControllerComponent)
        
        let geometryComponent = GeometryComponent<PlayerNode>(geometryNode: self.objCharacter)
        addComponent(geometryComponent)
        
        addAgent()
        objCharacter.lastPos = agent.position
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
    
    func addAgent() {
//        let agent = agent
        
        agent.delegate = self
        agent.position = SIMD2(x: Float(objCharacter.position.x), y: Float(objCharacter.position.y))
        agent.mass = 0.01
        agent.maxSpeed = 500
        agent.maxAcceleration = 1000
        
        addComponent(agent)
    }
}
