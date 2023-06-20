//
//  TriggerEntity.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 20/06/23.
//

import GameplayKit
import SpriteKit

class TriggerEntity: GKEntity {
    let spriteName: String
    var role: RoleType
    var objTrigger: TriggerNode
    init(name: String, role: RoleType) {
        self.spriteName = name
        self.role = role
        
        self.objTrigger = TriggerNode(imageNamed: self.spriteName)
        super.init()
        if self.role == .Switch {
            makeSwitch()
        } else if self.role == .HideOut {
            
        } else if self.role == .Cage {
            
        } else if self.role == .Timer {
            
        }
        
    }
    
    func makeSwitch() {
        self.objTrigger.totalTrigger = 1
        self.objTrigger.physicsBody = SKPhysicsBody(rectangleOf: self.objTrigger.size)
        self.objTrigger.physicsBody?.isDynamic = false
        self.objTrigger.physicsBody?.affectedByGravity = false
        self.objTrigger.physicsBody?.allowsRotation = false
        self.objTrigger.position = CGPoint(x: 0, y: 50)
        self.objTrigger.physicsBody?.categoryBitMask = 0x100
        self.objTrigger.physicsBody?.contactTestBitMask = 0x10
        self.objTrigger.setScale(0.1)
        
        let geometryComponent = GeometryComponent(geometryNode: self.objTrigger)
        self.addComponent(geometryComponent)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



enum RoleType {
    case Switch, HideOut, Cage, Timer
}
