//
//  EnemyControllerComponent.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 27/06/23.
//

import Foundation
import GameplayKit
import SpriteKit

class EnemyControllerComponent: GKComponent {
    var geometryComponent: GeometryComponent<EnemyEntity>? {
        return entity?.component(ofType: GeometryComponent.self)
    }
    
    var AIDownTexture: [SKTexture] = []
    var AIDown: SKAction = SKAction()
    var AIUpTexture: [SKTexture] = []
    var AIUp: SKAction = SKAction()
    var AIRightTexture: [SKTexture] = []
    var AIRight: SKAction = SKAction()
    var AILeftTexture: [SKTexture] = []
    var AILeft: SKAction = SKAction()
    
    var lastMovement: lastMove = .none
    
    
    
    var obstacles: [GKPolygonObstacle] = []
    var obstacleGraph: GKObstacleGraph<GKGraphNode2D>!
    
    init(walls: [SKNode]) {
        obstacles = SKNode.obstacles(fromNodePhysicsBodies: walls)
        obstacleGraph = GKObstacleGraph(obstacles: obstacles, bufferRadius: 60.0)
        super.init()
        for i in 0...11 {
            AIDownTexture.append(SKTexture(imageNamed: "HumanDown/\(i)"))
            AIUpTexture.append(SKTexture(imageNamed: "HumanUp/\(i)"))
        }
        
        for i in 0...23 {
            AILeftTexture.append(SKTexture(imageNamed: "HumanLeft/\(i)"))
            AIRightTexture.append(SKTexture(imageNamed: "HumanRight/\(i)"))
        }
        AIDown = SKAction.animate(with: AIDownTexture, timePerFrame: 0.1)
        AIUp = SKAction.animate(with: AIUpTexture, timePerFrame: 0.1)
        AIRight = SKAction.animate(with: AIRightTexture, timePerFrame: 0.075)
        AILeft = SKAction.animate(with: AILeftTexture, timePerFrame: 0.075)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makePathFinding(target: PlayerEntity) {
        let direction = target.agent.position - target.objCharacter.lastPos
        var positionXDif: Float = 0
        var positionYDif: Float = 0
        
//        print(direction.x)
//        print(direction.y)
        
        if direction.x > 0 && direction.y > 0 {
            print("diagonal")
            positionXDif = 80
            positionYDif = 80
        } else if direction.x > 0 && direction.y < 0{
//            print("diagonal")
            positionXDif = 80
            positionYDif = -80
        } else if direction.x < 0 && direction.y < 0{
//            print("diagonal")
            positionXDif = -80
            positionYDif = -80
        } else if direction.x < 0 && direction.y > 0{
//            print("diagonal")
            positionXDif = -80
            positionYDif = 80
        } else if direction.x > 0 {
            positionXDif = 80
            if lastMovement != .right {
                geometryComponent?.geometryNode.objCharacter.run(SKAction.repeatForever(AIRight))
                lastMovement = .right
            }
        } else if direction.x == 0 {
            positionXDif = 0
        } else {
            positionXDif = -80
            if lastMovement != .left {
                geometryComponent?.geometryNode.objCharacter.run(SKAction.repeatForever(AILeft))
                lastMovement = .left
            }
        }
        
        if direction.y > 0 {
            positionYDif = 80
            if lastMovement != .up {
                geometryComponent?.geometryNode.objCharacter.run(SKAction.repeatForever(AIUp))
                lastMovement = .up
            }
        } else if direction.y == 0 {
            positionYDif = 0
        } else {
            positionYDif = -80
            if lastMovement != .down {
                geometryComponent?.geometryNode.objCharacter.run(SKAction.repeatForever(AIDown))
                lastMovement = .down
            }
        }
        
        let endNode = GKGraphNode2D(point: target.agent.position + SIMD2(x: positionXDif, y: positionYDif))
        obstacleGraph.connectUsingObstacles(node: endNode, ignoringBufferRadiusOf: obstacles)
        let startNode = GKGraphNode2D(point: geometryComponent?.geometryNode.agent.position ?? vector_float2(repeating: 0))
        obstacleGraph.connectUsingObstacles(node: startNode, ignoringBufferRadiusOf: obstacles)
        
        let pathNodes = obstacleGraph.findPath(from: startNode, to: endNode) as? [GKGraphNode2D]
        
        if !pathNodes!.isEmpty {
            let path = GKPath(graphNodes: pathNodes!, radius: 1.0)
            let followPath = GKGoal(toFollow: path, maxPredictionTime: 1.0, forward: true)
            let stayOnPath = GKGoal(toStayOn: path, maxPredictionTime: 1.0)
            
            let behaviors = GKBehavior(goals: [followPath, stayOnPath], andWeights: [1, 1])
            
            geometryComponent?.geometryNode.agent.behavior = behaviors
        }
        
        obstacleGraph.remove([startNode, endNode])
    }
    
//    func animateMove(arrowPress: lastMove, movement: SKAction) {
//        if arrowPress != lastMovement {
//        geometryComponent?.geometryNode.objCharacter.run(SKAction.repeatForever(movement))
//            print("Ubah Arah").obj
//        }
//    }
}

