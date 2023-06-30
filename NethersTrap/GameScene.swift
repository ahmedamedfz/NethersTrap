//
//  GameScene.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 16/06/23.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var playerEntities = [PlayerEntity]()
    var TriggerEntities = [TriggerEntity]()
    var cameraNode: SKCameraNode!

    private var lastUpdateTime : TimeInterval = 0
    
    var enemyEntity: EnemyEntity = EnemyEntity(name: "enemy", role: "Enemy", spriteImage: "", walls: [])
    var player1Entity: PlayerEntity = PlayerEntity(name: "", role: "Player", spriteImage: "")
    var player2Entity: PlayerEntity = PlayerEntity(name: "", role: "Player", spriteImage: "")
    var player3Entity: PlayerEntity = PlayerEntity(name: "", role: "Player", spriteImage: "")
    var player4Entity: PlayerEntity = PlayerEntity(name: "", role: "Player", spriteImage: "")
    var chaseBehavior: GKBehavior?
    
    var walls: [SKNode] = []
    
    let totalHideOut = 12
    var totalSwitchOn = 0
    let totalSwitch = 4
    
    var countUpdate = 0
    
    var spawnPaintingSpots: [SKNode] = []
    
    var spawnTrashCanSpots: [SKNode] = []
    
    var spawnSwitchSpots: [SKNode] = []
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        scene?.enumerateChildNodes(withName: "MapCollider") { node, _ in
            self.walls.append(node)
        }
        setupGameSceneInteractable()
        setupEntities()
        
    }
    
    func setupGameSceneInteractable(){
        
        let paintingImage = ["PaintingHideOutA","PaintingHideOutB","PaintingHideOutC"]
        let trashCanImage = ["TrashCanHideOutA","TrashCanHideOutB"]
        let paintingHideOut = Int.random(in: 0...totalHideOut)
        let trashCanHideOut = totalHideOut - paintingHideOut
        
        
        scene?.enumerateChildNodes(withName: "TrashCan") { node, _ in
                    self.spawnTrashCanSpots.append(node)
                    node.isHidden = true
                }
        scene?.enumerateChildNodes(withName: "Painting") { node, _ in
                    self.spawnPaintingSpots.append(node)
                    node.isHidden = true
                }
        scene?.enumerateChildNodes(withName: "Switch") { node, _ in
                    self.spawnSwitchSpots.append(node)
                    node.isHidden = true
                }
        for h in 1..<paintingHideOut+1 {
            
            
            let paintingElement = spawnPaintingSpots
            let selectedPaintingElement = paintingElement.randomElement()
            
            let hideOutEntity = TriggerEntity(name: "hideOutPainting\(h)", type: .HideOut, spriteImage: paintingImage.randomElement()!, pos: selectedPaintingElement!.position)
            addChild(hideOutEntity.objTrigger)
            TriggerEntities.append(hideOutEntity)
            selectedPaintingElement?.isHidden = false
        }
        
        for i in 1..<trashCanHideOut+1 {
            
            let trashCanElement = spawnTrashCanSpots
            let selectedTrashCanElement = trashCanElement.randomElement()
            
            let hideOutEntity = TriggerEntity(name: "hideOutTrashCan\(i)", type: .HideOut, spriteImage: trashCanImage.randomElement()!, pos: selectedTrashCanElement!.position)
            addChild(hideOutEntity.objTrigger)
            TriggerEntities.append(hideOutEntity)
            selectedTrashCanElement?.isHidden = false
        }
        
        for j in 0..<totalSwitch {
            let switchElement = spawnSwitchSpots
            
            let selectedSwitchElement = switchElement.randomElement()
            
            let switchEntity = TriggerEntity(name: "switch\(j)", type: .Switch, spriteImage: "00_Statue", pos: selectedSwitchElement!.position)
            addChild(switchEntity.objTrigger)
            TriggerEntities.append(switchEntity)
            selectedSwitchElement?.isHidden = false
        }
        
        let portalEntity = TriggerEntity(name: "portal", type: .Portal, spriteImage: "portalAssets", pos: CGPoint(x: 50, y: 450))
        addChild(portalEntity.objTrigger)
        TriggerEntities.append(portalEntity)
        portalEntity.objTrigger.isHidden = true
        
    }
    
    func setupEntities() {
        player1Entity = PlayerEntity(name: "player1", role: "Player", spriteImage: "GhostADown/0")
        addChild(player1Entity.objCharacter)
        
        let playerNameLabel = SKLabelNode(fontNamed: "Helvetica")
        playerNameLabel.text = player1Entity.nameEntity
        playerNameLabel.fontSize = 10
        playerNameLabel.fontColor = SKColor.green
        playerNameLabel.horizontalAlignmentMode = .center
        playerNameLabel.position = CGPoint(x: player1Entity.objCharacter.position.x, y: player1Entity.objCharacter.position.y + player1Entity.objCharacter.size.height/2)
        player1Entity.objCharacter.addChild(playerNameLabel)
        
        let pressLabel = SKLabelNode(fontNamed: "Helvetica")
        pressLabel.text = "Press F to hide"
        pressLabel.name = "Press"
        pressLabel.fontSize = 10
        pressLabel.fontColor = SKColor.green
        pressLabel.horizontalAlignmentMode = .left
        pressLabel.isHidden = true
        pressLabel.position = CGPoint(x: player1Entity.objCharacter.position.x + player1Entity.objCharacter.position.x + 10  , y: player1Entity.objCharacter.position.y )
        player1Entity.objCharacter.addChild(pressLabel)
        
        
        enemyEntity = EnemyEntity(name: "enemy", role: "Enemy", spriteImage: "GhostADown/0", walls: walls)
        addChild(enemyEntity.objCharacter)
        
        playerEntities = [player1Entity]
        
        makeCamera()
    }
    
    func makeCamera() {
        cameraNode = SKCameraNode()
        cameraNode.xScale = 200 / 100
        cameraNode.yScale = 200 / 100
        camera = cameraNode
        addChild(cameraNode)
    }
    

    func didBegin(_ contact: SKPhysicsContact) {
        let collision:UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if playerEntities[0].objCharacter.hit.isEmpty {
            if collision == 0x10 | 0x100 {
                let index = TriggerEntities.firstIndex(where: {$0.objTrigger.name == contact.bodyB.node?.name})
                playerEntities[0].objCharacter.idxSwitchVisited = index ?? 0
                print("Switch")
                playerEntities[0].objCharacter.hit = "Switch"
            } else if collision == 0x10 | 0x1000 && !playerEntities[0].objCharacter.deathAnimating {
                print("Catched")
                playerEntities[0].objCharacter.hit = "Catched"
                playerEntities[0].objCharacter.deathAnimating = true
                playerEntities[0].component(ofType: PlayerControllerComponent.self)?.animateDeath()
            } else if collision == 0x10 | 0x10000 {
                print("Hide")
                playerEntities[0].objCharacter.hidingRange = true
            } else if collision == 0x10 | 0x100000 && totalSwitchOn == 1 {
                playerEntities[0].objCharacter.isMovement = false
                playerEntities[0].objCharacter.isHidden = true
                print("win")
                enemyEntity.agent.behavior = nil
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        playerEntities[0].objCharacter.hit = ""
        playerEntities[0].objCharacter.idxSwitchVisited = -1
//        playerEntities[0].objCharacter.isHidden = false
        playerEntities[0].objCharacter.hidingRange = false
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0:
            playerEntities[0].objCharacter.left = true
        case 2:
            playerEntities[0].objCharacter.right = true
        case 1:
            playerEntities[0].objCharacter.down = true
        case 13:
            playerEntities[0].objCharacter.up = true
        case 3:
            if playerEntities[0].objCharacter.idxSwitchVisited != -1 && !TriggerEntities[playerEntities[0].objCharacter.idxSwitchVisited].objTrigger.isOn  {
                TriggerEntities[playerEntities[0].objCharacter.idxSwitchVisited].objTrigger.isOn = true
                totalSwitchOn += 1
            } else if playerEntities[0].objCharacter.hidingRange {
                playerEntities[0].objCharacter.isHidden = true
                playerEntities[0].objCharacter.isMovement = false
                enemyEntity.agent.behavior = nil
                
                run(SKAction.repeat(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.run(startCountDown)]), count: 5)) {
                    if !self.playerEntities[0].objCharacter.isHidden {
                        
                    }
                }
            } else {
                
                playerEntities[0].component(ofType: PlayerControllerComponent.self)?.unHide()
            }
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    func startCountDown() {
        playerEntities[0].component(ofType: PlayerControllerComponent.self)?.countDown()
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 0:
            playerEntities[0].objCharacter.left = false
        case 2:
            playerEntities[0].objCharacter.right = false
        case 1:
            playerEntities[0].objCharacter.down = false
        case 13:
            playerEntities[0].objCharacter.up = false
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
        playerEntities[0].component(ofType: PlayerControllerComponent.self)?.movement(dt: dt, camera: cameraNode)

        // Agent Update
        player1Entity.agent.update(deltaTime: dt)
        enemyEntity.agent.update(deltaTime: dt)
        
        enemyEntity.component(ofType: EnemyControllerComponent.self)?.makePathFinding(target: player1Entity)
        player1Entity.objCharacter.lastPos = player1Entity.agent.position

        self.lastUpdateTime = currentTime
    }
    
    override func didEvaluateActions() {
        let dX = playerEntities[0].objCharacter.position.x - cameraNode.position.x
        let dY = playerEntities[0].objCharacter.position.y - cameraNode.position.y
        let distance = hypot(dX, dY)
        
        if distance > 1.0 {
            cameraNode.position.x += dX * 0.2
            cameraNode.position.y += dY * 0.2
        } else {
            cameraNode.position = playerEntities[0].objCharacter.position
        }
        
    }
}
