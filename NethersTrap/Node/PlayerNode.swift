//
//  CharacterNode.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 20/06/23.
//

import GameplayKit
import SpriteKit

class PlayerNode: SKSpriteNode {
    var left = false
    var right = false
    var up = false
    var down = false
    var deathAnimating = false
    var hit = ""
    var hidingRange = false
    var isMovement = true
    var timeHiding = 5
    var idxSwitchVisited = -1
    var lastPos = vector_float2(arrayLiteral: 0, 0)
    var isAlive = false
}
