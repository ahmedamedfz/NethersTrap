//
//  TriggerEntity.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 20/06/23.
//

import GameplayKit
import SpriteKit

class TriggerEntity: GKEntity {
//    let nameEntity: String
    var type: EntityType
    var objTrigger: TriggerNode
//    var isOn: Bool = false
    
    init(name: String, type: EntityType, spriteImage: String, pos: CGPoint) {
        self.type = type
        objTrigger = TriggerNode(imageNamed:spriteImage)
        objTrigger.name = name
        objTrigger.position = pos
        super.init()
        makeTrigger()
        
        
    }
    
    func makeTrigger() {
        objTrigger.size = CGSize(width: 20, height: 30)
        objTrigger.physicsBody = SKPhysicsBody(rectangleOf: objTrigger.size)
        objTrigger.physicsBody?.isDynamic = false
        objTrigger.physicsBody?.affectedByGravity = false
        objTrigger.physicsBody?.allowsRotation = false
        objTrigger.alpha = 1
        objTrigger.physicsBody?.contactTestBitMask = 0x10
        objTrigger.setScale(0.8)
        
        if type == .Switch {
            defineSwitch()
        } else if type == .HideOut {
            defineHideOut()
        } else if type == .Cage {
            
        } else if type == .Timer {
            
        } else if type == .Portal {
            definePortal()
        }
        
        let geometryComponent = GeometryComponent<SKSpriteNode>(geometryNode: objTrigger)
        self.addComponent(geometryComponent)
    }
    
    func defineHideOut() {
        objTrigger.physicsBody?.categoryBitMask = 0x10000
    }
    
    func defineSwitch() {
        objTrigger.physicsBody?.categoryBitMask = 0x100
    }
    
    func definePortal() {
        objTrigger.physicsBody?.categoryBitMask = 0x100000
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



enum EntityType {
    case Switch, HideOut, Cage, Timer, Portal
}
