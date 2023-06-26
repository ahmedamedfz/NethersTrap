//
//  GameScene.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 16/06/23.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var characterEntities = [CharEntity]()
    var TriggerEntities = [TriggerEntity]()
    var cameraNode: SKCameraNode!
//    var triggerLamp: SKSpriteNode!
    
//    static public var instance: GameScene = GameScene()
    private var lastUpdateTime : TimeInterval = 0
    
    var enemyEntity: CharEntity = CharEntity(name: "enemy", role: .Enemy, spriteImage: "")
    var player1Entity: CharEntity = CharEntity(name: "", role: .Player, spriteImage: "")
    var player2Entity: CharEntity = CharEntity(name: "", role: .Player, spriteImage: "")
    var player3Entity: CharEntity = CharEntity(name: "", role: .Player, spriteImage: "")
    var player4Entity: CharEntity = CharEntity(name: "", role: .Player, spriteImage: "")
    var agents: [GKAgent2D] = []
    var chaseBehavior: GKBehavior?
    
    var walls: [SKNode] = []
    var obstacles: [GKPolygonObstacle] = []
    var obstacleGraph: GKObstacleGraph<GKGraphNode2D>!
    
    let totalHideOut = 3
    var totalSwitchOn = 0
    
    var spawnHideOutSpots: [[Int]:Bool] = [
        [25,25]:false,
        [50,50]:false,
        [100,50]:false,
        [50,100]:false,
        [150,50]:false,
        [50,150]:false,
    ]
    
    let playerControlComponentSystem = GKComponentSystem(componentClass: PlayerControllerComponent.self)
    
    
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        scene?.enumerateChildNodes(withName: "MapCollider") { node, _ in
            self.walls.append(node)
        }
        obstacles = SKNode.obstacles(fromNodePhysicsBodies: walls)
        obstacleGraph = GKObstacleGraph(obstacles: obstacles, bufferRadius: 60.0)
        
        setupEntities()
//        addComponentsToComponentSystems()
    }
    
    func setupEntities() {
        player1Entity = CharEntity(name: "player1", role: .Player, spriteImage: "GhostADown/0")
        addChild(player1Entity.objCharacter)
        addAgent(entityNode: player1Entity)
        
        enemyEntity = CharEntity(name: "enemy", role: .Enemy, spriteImage: "GhostADown/0")
        addChild(enemyEntity.objCharacter)
        addAgent(entityNode: enemyEntity)
        
        let switchEntity = TriggerEntity(name: "switch1", type: .Switch, spriteImage: "Cobblestone_Grid_Center", pos: CGPoint(x: 0, y: 50))
        addChild(switchEntity.objTrigger)
        TriggerEntities.append(switchEntity)
        
        for i in 1...totalHideOut {
            let specificElement = spawnHideOutSpots.filter { $0.value == false }.map { $0.key }
            let selectedElement = specificElement.randomElement()
            let posX = selectedElement?.first ?? 0
            let posY = selectedElement?.last ?? 0
            
            let hideOutEntity = TriggerEntity(name: "hideOut\(i)", type: .HideOut, spriteImage: "hideOutAssets", pos: CGPoint(x: posX, y: posY))
            addChild(hideOutEntity.objTrigger)
            TriggerEntities.append(hideOutEntity)
            spawnHideOutSpots[selectedElement ?? [0]] = true
        }
        
        let portalEntity = TriggerEntity(name: "portal", type: .Portal, spriteImage: "portalAssets", pos: CGPoint(x: -50, y: 50))
        addChild(portalEntity.objTrigger)
        TriggerEntities.append(portalEntity)
        characterEntities = [enemyEntity, player1Entity]
        
        makeCamera()
    }
    
    func makeCamera() {
        cameraNode = SKCameraNode()
        cameraNode.xScale = 200 / 100
        cameraNode.yScale = 200 / 100
        camera = cameraNode
        addChild(cameraNode)
    }
    
    func addAgent(entityNode: CharEntity) {
        let entity = entityNode.objCharacter.entity
        let agent = entityNode.agent
        
//        var mapBound: [SKNode] = []
//        scene?.enumerateChildNodes(withName: "MapCollider") { node, _ in
//            mapBound.append(node)
//        }
//        let obstacles = SKNode.obstacles(fromNodePhysicsBodies: mapBound)
//        let mapGraph = GKObstacleGraph(obstacles: obstacles, bufferRadius: 2)
//        let mapNodes = mapGraph.nodes
//        let mapPath = GKPath(graphNodes: mapNodes!, radius: 1.0)
//
//        print(mapNodes)
        
        agent.delegate = entityNode
        agent.position = SIMD2(x: Float(entityNode.objCharacter.position.x), y: Float(entityNode.objCharacter.position.y))
        
//        if entityNode.role == .Enemy {
//            chaseBehavior = GKBehavior(goals:
//                                        [GKGoal(toAvoid: obstacles, maxPredictionTime: 2.0),
//                                         GKGoal(toFollow: mapPath, maxPredictionTime: 2.0, forward: true),
//                                         GKGoal(toStayOn: mapPath, maxPredictionTime: 2.0),
//                                         GKGoal(toSeekAgent: player1Entity.agent),
//                                         GKGoal(toWander: 2.0),
//                                         GKGoal(toInterceptAgent: player1Entity.agent, maxPredictionTime: 2.0)])
//
//            agent.behavior = chaseBehavior
        agent.mass = 0.01
        agent.maxSpeed = 200
        agent.maxAcceleration = 1000
//        }
        
        entity?.addComponent(agent)
    }
    
    func makePathFinding() {
        let endNode = GKGraphNode2D(point: player1Entity.agent.position)
        obstacleGraph.connectUsingObstacles(node: endNode, ignoringBufferRadiusOf: obstacles)
        let startNode = GKGraphNode2D(point: enemyEntity.agent.position)
        obstacleGraph.connectUsingObstacles(node: startNode, ignoringBufferRadiusOf: obstacles)
        
        let pathNodes = obstacleGraph.findPath(from: startNode, to: endNode) as? [GKGraphNode2D]
        
        if !pathNodes!.isEmpty {
            let path = GKPath(graphNodes: pathNodes!, radius: 1.0)
            let followPath = GKGoal(toFollow: path, maxPredictionTime: 1.0, forward: true)
            let stayOnPath = GKGoal(toStayOn: path, maxPredictionTime: 1.0)
            
            let behaviors = GKBehavior(goals: [followPath, stayOnPath], andWeights: [1, 1])
            
            enemyEntity.agent.behavior = behaviors
        }
        
        obstacleGraph.remove([startNode, endNode])
    }
    
//    func addComponentsToComponentSystems() {
//        for ent in characterEntities {
//            playerControlComponentSystem.addComponent(foundIn: ent)
//        }
//    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision:UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if characterEntities[1].objCharacter.hit.isEmpty {
            if collision == 0x10 | 0x100 {
//                let entity = TriggerEntities.filter { $0.objTrigger.name == contact.bodyB.node?.name ?? "" }
                let index = TriggerEntities.firstIndex(where: {$0.objTrigger.name == contact.bodyB.node?.name})
                characterEntities[1].objCharacter.idxSwitchVisited = index ?? 0
//                print(test.first?.objTrigger.name ?? "")
                print("Switch")
                characterEntities[1].objCharacter.hit = "Switch"
//                characterEntities[1].objCharacter.isHidden = true
            } else if collision == 0x10 | 0x1000 && !characterEntities[1].objCharacter.deathAnimating {
                print("Catched")
                characterEntities[1].objCharacter.hit = "Catched"
                characterEntities[1].objCharacter.deathAnimating = true
//                animateDeath()
//                for case let component as PlayerControllerComponent in playerControlComponentSystem.components {
//                    component.animateDeath()
//                }
                characterEntities[1].component(ofType: PlayerControllerComponent.self)?.animateDeath()
            } else if collision == 0x10 | 0x10000 {
                print("Hide")
                characterEntities[1].objCharacter.hidingRange = true
            } else if collision == 0x10 | 0x100000 && totalSwitchOn == 1 {
                characterEntities[1].objCharacter.isMovement = false
                characterEntities[1].objCharacter.isHidden = true
                print("win")
                enemyEntity.agent.behavior = nil
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        characterEntities[1].objCharacter.hit = ""
        characterEntities[1].objCharacter.idxSwitchVisited = -1
//        characterEntities[1].objCharacter.isHidden = false
        characterEntities[1].objCharacter.hidingRange = false
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0:
            characterEntities[1].objCharacter.left = true
        case 2:
            characterEntities[1].objCharacter.right = true
        case 1:
            characterEntities[1].objCharacter.down = true
        case 13:
            characterEntities[1].objCharacter.up = true
        case 3:
            if characterEntities[1].objCharacter.idxSwitchVisited != -1 && !TriggerEntities[characterEntities[1].objCharacter.idxSwitchVisited].isOn  {
                TriggerEntities[characterEntities[1].objCharacter.idxSwitchVisited].isOn = true
                totalSwitchOn += 1
            }else if characterEntities[1].objCharacter.hidingRange {
                characterEntities[1].objCharacter.isHidden = true
                characterEntities[1].objCharacter.isMovement = false
                enemyEntity.agent.behavior = nil
                run(SKAction.repeat(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.run(startCountDown)]), count: 5)) {
                    if !self.characterEntities[1].objCharacter.isHidden {
                        self.enemyEntity.agent.behavior = self.chaseBehavior
                    }
                }
            } else {
                self.enemyEntity.agent.behavior = self.chaseBehavior
                characterEntities[1].component(ofType: PlayerControllerComponent.self)?.unHide()
//                unHide()
            }
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    func startCountDown() {
        characterEntities[1].component(ofType: PlayerControllerComponent.self)?.countDown()
    }
    
//    func unHide() {
//        for case let component as PlayerControllerComponent in playerControlComponentSystem.components {
//            component.unHide()
//        }
//    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 0:
            characterEntities[1].objCharacter.left = false
        case 2:
            characterEntities[1].objCharacter.right = false
        case 1:
            characterEntities[1].objCharacter.down = false
        case 13:
            characterEntities[1].objCharacter.up = false
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        characterEntities[1].component(ofType: PlayerControllerComponent.self)?.movement(dt: dt, camera: cameraNode)
//        for case let component as PlayerControllerComponent in playerControlComponentSystem.components {
//            component.movement(moveLeft: characterEntities[1].objCharacter.left, moveRight: characterEntities[1].objCharacter.right, moveUp: characterEntities[1].objCharacter.up, moveDown: characterEntities[1].objCharacter.down, dt: dt, camera: cameraNode, speed: characterEntities[1].objCharacter.walkSpeed, isMovement: characterEntities[1].objCharacter.isMovement)
//        }
        
        // Agent Update
        player1Entity.agent.update(deltaTime: dt)
        enemyEntity.agent.update(deltaTime: dt)
        
        makePathFinding()
            
        self.lastUpdateTime = currentTime
    }
}
