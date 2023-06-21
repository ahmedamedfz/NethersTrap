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
    var type: EntityType
    var objTrigger: TriggerNode
    init(name: String, type: EntityType) {
        self.spriteName = name
        self.type = type
        
        self.objTrigger = TriggerNode(imageNamed: self.spriteName)
        super.init()
        makeTrigger()
        
        
    }
    
    func makeTrigger() {
        self.objTrigger.totalTrigger = 1
        self.objTrigger.physicsBody = SKPhysicsBody(rectangleOf: self.objTrigger.size)
        self.objTrigger.physicsBody?.isDynamic = false
        self.objTrigger.physicsBody?.affectedByGravity = false
        self.objTrigger.physicsBody?.allowsRotation = false
        self.objTrigger.alpha = 1
        self.objTrigger.physicsBody?.contactTestBitMask = 0x10
        self.objTrigger.setScale(0.1)
        
        if self.type == .Switch {
            defineSwitch()
        } else if self.type == .HideOut {
            defineHideOut()
        } else if self.type == .Cage {
            
        } else if self.type == .Timer {
            
        }
        
        let geometryComponent = GeometryComponent(geometryNode: self.objTrigger)
        self.addComponent(geometryComponent)
    }
    
    func defineHideOut() {
        self.objTrigger.position = CGPoint(x: 30, y: 50)
        self.objTrigger.physicsBody?.categoryBitMask = 0x10000
    }
    
    func defineSwitch() {
        self.objTrigger.position = CGPoint(x: 0, y: 50)
        self.objTrigger.physicsBody?.categoryBitMask = 0x100
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



enum EntityType {
    case Switch, HideOut, Cage, Timer
}
