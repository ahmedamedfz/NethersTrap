//
//  TriggerControllerComponent.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 30/06/23.
//

import Foundation
import GameplayKit
import SpriteKit

class TriggerControllerComponent: GKComponent {
    var geometryComponent: GeometryComponent<TriggerEntity>? {
        return entity?.component(ofType: GeometryComponent.self)
    }
    
    var switchAnim: SKAction = SKAction()
    var switchTexture: [SKTexture] = []
    
    override init() {
        super.init()
        for i in 0...4 {
            switchTexture.append(SKTexture(imageNamed: "Statues/\(i)"))
        }
        print("Switchtexture: \(switchTexture)")
        switchAnim = SKAction.animate(with: switchTexture, timePerFrame: 0.1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func statueOnAnim(statueOnImage: String) {
//        geometryComponent?.geometryNode.objTrigger.run(SKAction.repeatForever(switchAnim))
//        geometryComponent?.geometryNode.objTrigger.texture = SKTexture(imageNamed: statueOnImage)
//        print("run")
//    }
}
