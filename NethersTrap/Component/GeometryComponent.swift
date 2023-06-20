//
//  GeometryComponent.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 19/06/23.
//

import SpriteKit
import GameplayKit

class GeometryComponent: GKComponent {
    
    let geometryNode: SKSpriteNode
    
    init(geometryNode: SKSpriteNode) {
        self.geometryNode = geometryNode
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
