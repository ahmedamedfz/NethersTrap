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
    
    var obstacles: [GKPolygonObstacle] = []
    var obstacleGraph: GKObstacleGraph<GKGraphNode2D>!
    
    init(walls: [SKNode]) {
        obstacles = SKNode.obstacles(fromNodePhysicsBodies: walls)
        obstacleGraph = GKObstacleGraph(obstacles: obstacles, bufferRadius: 60.0)
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makePathFinding(target: PlayerEntity) {
        let direction = target.agent.position - target.objCharacter.lastPos
        var positionXDif: Float = 0
        var positionYDif: Float = 0
        
        if direction.x > 0 {
            positionXDif = 80
        } else if direction.x == 0 {
            positionXDif = 0
        } else {
            positionXDif = -80
        }
        
        if direction.y > 0 {
            positionYDif = 80
        } else if direction.y == 0 {
            positionYDif = 0
        } else {
            positionYDif = -80
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
}
