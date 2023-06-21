//
//  Entity.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 20/06/23.
//

import Foundation
import GameplayKit
import SpriteKit

class CharEntity: GKEntity {
    let spriteName: String
    var role: Role
    var objCharacter: CharacterNode
    var texture: SKTexture
    
    init(name: String, role: Role) {
        self.spriteName = name
        self.role = role
        texture = SKTexture(imageNamed: self.spriteName)
        self.objCharacter = CharacterNode(texture: texture)
        super.init()
        if self.role == .Player {
            self.makePlayer()
        } else if self.role == .Enemy {
            self.makeEnemy()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makePlayer() {
        self.objCharacter.walkSpeed = 40.0
        self.objCharacter.zPosition = 100
        self.objCharacter.position = CGPoint(x: 0, y: 0)
        self.objCharacter.setScale(0.4)
        self.objCharacter.physicsBody = SKPhysicsBody(texture: texture, size: self.objCharacter.size)
        self.objCharacter.physicsBody?.isDynamic = true
        self.objCharacter.physicsBody?.affectedByGravity = false
        self.objCharacter.physicsBody?.allowsRotation = false
        self.objCharacter.physicsBody?.categoryBitMask = 0x10
        self.objCharacter.physicsBody?.collisionBitMask = 0x1
        self.objCharacter.physicsBody?.contactTestBitMask = 0x100 | 0x1000
        print("masuk")
        
        
        let geometryComponent = GeometryComponent(geometryNode: self.objCharacter)
        self.addComponent(geometryComponent)
        
        let playerControllerComponent = PlayerControllerComponent()
        self.addComponent(playerControllerComponent)
    }
    
    func makeEnemy() {
        self.objCharacter.walkSpeed = 40.0
        self.objCharacter.zPosition = 100
        self.objCharacter.position = CGPoint(x: 50, y: 0)
        self.objCharacter.setScale(0.4)
        self.objCharacter.physicsBody = SKPhysicsBody(texture: texture, size: self.objCharacter.size)
        self.objCharacter.physicsBody?.isDynamic = true
        self.objCharacter.physicsBody?.affectedByGravity = false
        self.objCharacter.physicsBody?.allowsRotation = false
        self.objCharacter.physicsBody?.categoryBitMask = 0x1000
        self.objCharacter.physicsBody?.collisionBitMask = 0x1
        self.objCharacter.physicsBody?.contactTestBitMask = 0x10
        
        let geometryComponent = GeometryComponent(geometryNode: self.objCharacter)
        self.addComponent(geometryComponent)
    }
}

enum Role {
    case Player, Enemy
}
