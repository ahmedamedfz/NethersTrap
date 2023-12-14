//
//  GameScene.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 16/06/23.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let returnButton = SKSpriteNode(imageNamed: "returnButton")
    let loseText = SKSpriteNode(imageNamed: "capturedText")
    
    var playerEntities = [PlayerEntity]()
    var TriggerEntities = [TriggerEntity]()
    var cameraNode: SKCameraNode!
    
    private var lastUpdateTime : TimeInterval = 0
    
    var enemyEntity: EnemyEntity = EnemyEntity(name: "enemy", role: "Enemy", spriteImage: "", walls: [], pos: CGPoint(x: 0, y: 0))
    var player1Entity: PlayerEntity = PlayerEntity(name: "", role: "Player", spriteImage: "")
    var player2Entity: PlayerEntity = PlayerEntity(name: "", role: "Player", spriteImage: "")
    
    
    var overlayShadow = SKSpriteNode(imageNamed: "Shadow")
    var switchAnim: SKAction = SKAction()
    var portalAnim: SKAction = SKAction()
    var switchTexture: [SKTexture] = []
    var elevatorTexture: [SKTexture] = []
    var currStatue: SKSpriteNode = SKSpriteNode(imageNamed: "Statues/0")
    var currPortal: SKSpriteNode = SKSpriteNode(imageNamed: "Elevators/0")
    var walls: [SKNode] = []
    var lift: SKNode = SKNode()
    var statueCountLabel: SKLabelNode?
    var statusWinningLabel: SKLabelNode?
    var wanderGraph: [GKGraphNode2D]?
    var wanderBehavior = GKBehavior()
    var isLose : Bool = false
    
    let totalHideOut = 10
    var totalSwitchOn = 0
    let totalSwitch = 4
    
    var spawnPaintingSpots: [SKNode] = []
    var spawnTrashCanSpots: [SKNode] = []
    var spawnSwitchSpots: [SKNode] = []
    var spawnEnemySpots: [SKNode] = []
    
    override func sceneDidLoad() {
        SoundManager.soundHelper.bgmPlayer.play()
        self.lastUpdateTime = 0
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        
        scene?.enumerateChildNodes(withName: "MapCollider") { node, _ in
            self.walls.append(node)
        }
        
        setupEntities()
        setupGameSceneInteractable()
        
        scene?.enumerateChildNodes(withName: "LiftCollider") { node, _ in
            self.lift = node
        }
        
        for i in 0...4 {
            switchTexture.append(SKTexture(imageNamed: "Statues/\(i)"))
        }
        switchAnim = SKAction.animate(with: switchTexture, timePerFrame: 0.1)
        
        for j in 0...5 {
            elevatorTexture.append(SKTexture(imageNamed: "Elevators/\(j)"))
        }
        print("Elevatortexture: \(elevatorTexture)")
        portalAnim = SKAction.animate(with: elevatorTexture, timePerFrame: 0.2)
        
        overlayShadow.zPosition = 6
        overlayShadow.setScale(0.4)
        overlayShadow.blendMode = .multiplyAlpha
        addChild(overlayShadow)
    }
    
    func setupGameSceneInteractable() {
        let paintingImage = ["PaintingHideOutA","PaintingHideOutB","PaintingHideOutC"]
        let trashCanImage = ["TrashCanHideOutA","TrashCanHideOutB"]
        let paintingHideOut = Int.random(in: 1...totalHideOut)
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
        
        for h in 0..<paintingHideOut {
            let paintingCount = spawnPaintingSpots.count
            let selectedPainting = spawnPaintingSpots.remove(at: Int.random(in: 0..<paintingCount))
            
            let hideOutEntity = TriggerEntity(name: "Painting\(h)", type: .HideOut, spriteImage: paintingImage.randomElement()!, pos: selectedPainting.position)
            addChild(hideOutEntity.objTrigger)
            TriggerEntities.append(hideOutEntity)
        }
        
        for i in 0..<trashCanHideOut {
            let trashCanCount = spawnTrashCanSpots.count
            let selectedTrashCan = spawnTrashCanSpots.remove(at: Int.random(in: 0..<trashCanCount))
            
            let hideOutEntity = TriggerEntity(name: "TrashCan\(i)", type: .HideOut, spriteImage: trashCanImage.randomElement()!, pos: selectedTrashCan.position)
            addChild(hideOutEntity.objTrigger)
            TriggerEntities.append(hideOutEntity)
        }
        
        for j in 0..<totalSwitch {
            let switchCount = spawnSwitchSpots.count
            let selectedSwitch = spawnSwitchSpots.remove(at: Int.random(in: 0..<switchCount))
            
            let switchEntity = TriggerEntity(name: "switch\(j)", type: .Switch, spriteImage: "Statues/0", pos: selectedSwitch.position)
            //            print("switch: \(switchEntity.objTrigger.name ?? "")")
            addChild(switchEntity.objTrigger)
            TriggerEntities.append(switchEntity)
        }
        
        let portalEntity = TriggerEntity(name: "portal", type: .Portal, spriteImage: "Elevators/0", pos: CGPoint(x: 36.519, y: 427.598))
        portalEntity.objTrigger.size = CGSize(width: 186.521, height: 161.353)
        portalEntity.objTrigger.zPosition = 2
        //        portalEntity.objTrigger.isHidden = false
        addChild(portalEntity.objTrigger)
        TriggerEntities.append(portalEntity)
    }
    
    func setupEntities() {
        let deviceName = Host.current().localizedName ?? ""
        player1Entity = PlayerEntity(name: "\(deviceName)", role: "Player", spriteImage: "GhostADown/0")
        player1Entity.objCharacter.zPosition = 4
        addChild(player1Entity.objCharacter)
        
        let playerNameLabel = SKLabelNode(fontNamed: "VT323-Regular")
        playerNameLabel.text = player1Entity.nameEntity
        playerNameLabel.fontSize = 10
        playerNameLabel.fontColor = SKColor.green
        playerNameLabel.horizontalAlignmentMode = .center
        playerNameLabel.position = CGPoint(x: player1Entity.objCharacter.position.x, y: player1Entity.objCharacter.position.y + player1Entity.objCharacter.size.height/2)
//        player1Entity.objCharacter.addChild(playerNameLabel)
        
        let pressLabel = SKLabelNode(fontNamed: "VT323-Regular")
        pressLabel.text = "Press F to hide"
        pressLabel.name = "Press"
        pressLabel.fontSize = 10
        pressLabel.fontColor = SKColor.green
        pressLabel.horizontalAlignmentMode = .left
        pressLabel.isHidden = true
        pressLabel.position = CGPoint(x: player1Entity.objCharacter.position.x + player1Entity.objCharacter.position.x + 10  , y: player1Entity.objCharacter.position.y )
        player1Entity.objCharacter.addChild(pressLabel)
        
        let pressLabelStatue = SKLabelNode(fontNamed: "VT323-Regular")
        pressLabelStatue.text = "Press F to activate"
        pressLabelStatue.name = "PressStatue"
        pressLabelStatue.fontSize = 10
        pressLabelStatue.fontColor = SKColor.green
        pressLabelStatue.horizontalAlignmentMode = .left
        pressLabelStatue.isHidden = true
        pressLabelStatue.position = CGPoint(x: player1Entity.objCharacter.position.x + player1Entity.objCharacter.position.x + 10  , y: player1Entity.objCharacter.position.y )
        player1Entity.objCharacter.addChild(pressLabelStatue)
        
        let path = GKPath(graphNodes: wanderGraph!, radius: 1.0)
        let followPath = GKGoal(toFollow: path, maxPredictionTime: 1.0, forward: true)
        let stayOnPath = GKGoal(toStayOn: path, maxPredictionTime: 1.0)
        
        wanderBehavior = GKBehavior(goals: [followPath, stayOnPath], andWeights: [1, 1])
        
        scene?.enumerateChildNodes(withName: "Enemy") { node, _ in
            self.spawnEnemySpots.append(node)
            node.isHidden = true
        }
        print("count: \(spawnEnemySpots.count)")
        let enemySpawnCount = spawnEnemySpots.count
        let selectedEnemy = spawnEnemySpots.remove(at: Int.random(in: 0..<enemySpawnCount))
        print("selectedEnemy: \(selectedEnemy.position)")
        enemyEntity = EnemyEntity(name: "enemy", role: "Enemy", spriteImage: "GhostADown/0", walls: walls, pos: selectedEnemy.position)
        enemyEntity.objCharacter.zPosition = 5
        enemyEntity.agent.behavior = wanderBehavior
        addChild(enemyEntity.objCharacter)
        
        playerEntities = [player1Entity]
        
        makeCamera()
        
        let statueImage = SKTexture(imageNamed: "CountStatue")
        let statueNode = SKSpriteNode(texture: statueImage)
        statueNode.size = CGSize(width: 50, height: 15)
        statueNode.position = CGPoint(x: 0, y: 87)
        statueNode.zPosition = 9
        cameraNode.addChild(statueNode)
        
        let statueCount = SKLabelNode(fontNamed: "VT323-Regular")
        statueCount.text = "\(totalSwitchOn)/\(totalSwitch)"
        statueCount.fontSize = 8
        statueCount.horizontalAlignmentMode = .left
        statueCount.fontColor = SKColor.white
        statueCount.zPosition = 10
//        statueCount.position = CGPoint(x: -10, y: 82)
        statueCount.position = CGPoint(x: -7, y: -5)
        statueNode.addChild(statueCount)
        
        self.statueCountLabel = statueCount
        
        let statusWinning = SKLabelNode(fontNamed: "VT323-Regular")
        statusWinning.text = "Find and Turn On All The Statue"
        statusWinning.fontSize = 6
        statusWinning.horizontalAlignmentMode = .center
        statusWinning.fontColor = SKColor.white
        statusWinning.zPosition = 10
//        statueCount.position = CGPoint(x: -10, y: 82)
        statusWinning.position = CGPoint(x: 0, y: -13)
        statueNode.addChild(statusWinning)
        
        self.statusWinningLabel = statusWinning
        
    }
    
    func makeCamera() {
        cameraNode = SKCameraNode()
        cameraNode.xScale = 200 / 100
        cameraNode.yScale = 200 / 100
        camera = cameraNode
        addChild(cameraNode)
        
    }
    
    func updateStatueCount(count: Int, total: Int) {
        guard let label = statueCountLabel else {
            return
        }
        
        label.text = "\(count)/\(total)"
    }
    
    func updateStatusWinning() {
        guard let label = statusWinningLabel else {
            return
        }
        
        label.text = "Find The Elevator to Escape"
        label.fontColor = SKColor.yellow
    }
    
    func setupLosingCondition() {
        loseText.size = CGSize(width: 423, height: 72)
        loseText.position = player1Entity.objCharacter.position
        loseText.position.y += 100
        loseText.name = "loseText"
        loseText.zPosition = 7
        
        
        returnButton.size = CGSize(width: 238, height: 38)
        returnButton.position = player1Entity.objCharacter.position
        returnButton.position.y -= 100
        returnButton.name = "returnButton"
        returnButton.zPosition = 7
        addChild(loseText)
        addChild(returnButton)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision:UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if playerEntities[0].objCharacter.hit.isEmpty {
            if collision == 0x10 | 0x100 {
                //                print("contact: ", contact.bodyA.node?.name ?? "")
                let index = TriggerEntities.firstIndex(where: {$0.objTrigger.name == contact.bodyB.node?.name})
                //                print("idx: ", index ?? 0)
                //                print("idx isOn: ", TriggerEntities[index ?? 0].objTrigger.isOn)
                playerEntities[0].objCharacter.idxSwitchVisited = index ?? 0
                print("Switch")
                if !TriggerEntities[playerEntities[0].objCharacter.idxSwitchVisited].objTrigger.isOn {
                    print("masuk")
                    player1Entity.objCharacter.childNode(withName: "PressStatue")?.isHidden = false
                    playerEntities[0].objCharacter.hit = "Switch"
                }
                
            } else if collision == 0x10 | 0x1000 && !playerEntities[0].objCharacter.deathAnimating {
                if !playerEntities[0].objCharacter.isHidden {
                    print("Catched")
                    SoundManager.soundHelper.killedSFX.play()
                    playerEntities[0].objCharacter.physicsBody?.contactTestBitMask = 0
                    playerEntities[0].objCharacter.hit = "Catched"
                    playerEntities[0].objCharacter.deathAnimating = true
                    playerEntities[0].objCharacter.isMovement = false
                    playerEntities[0].objCharacter.isHidden = true
                    enemyEntity.agent.behavior = nil
                    enemyEntity.agent.maxSpeed = 0
                    enemyEntity.agent.maxAcceleration = 0
                    enemyEntity.objCharacter.run(enemyEntity.component(ofType: EnemyControllerComponent.self)!.AIDead)
                    isLose = true
                    setupLosingCondition()
                    
                    
                    playerEntities[0].component(ofType: PlayerControllerComponent.self)?.animateDeath()
                }
            } else if collision == 0x10 | 0x10000 {
                //                print("contact: ", contact.bodyA.node?.name ?? "")
                print("Hide")
                player1Entity.objCharacter.childNode(withName: "Press")?.isHidden = false
                playerEntities[0].objCharacter.hidingRange = true
            } else if collision == 0x10 | 0x100000 && totalSwitchOn == totalSwitch {
                //                print("contact: ", contact.bodyA.node?.name ?? "")
                playerEntities[0].objCharacter.isMovement = false
                playerEntities[0].objCharacter.isHidden = true
                let newScene = WinningScreen(size: (view?.bounds.size)!)
                newScene.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 2) //
                self.view?.presentScene(newScene, transition: transition)
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
        player1Entity.objCharacter.childNode(withName: "Press")?.isHidden = true
        player1Entity.objCharacter.childNode(withName: "PressStatue")?.isHidden = true
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0, 123:
            playerEntities[0].objCharacter.left = true
        case 2, 124:
            playerEntities[0].objCharacter.right = true
        case 1, 125:
            playerEntities[0].objCharacter.down = true
        case 13, 126:
            playerEntities[0].objCharacter.up = true
        case 3:
            if (isLose == false){
                if playerEntities[0].objCharacter.idxSwitchVisited != -1 && !TriggerEntities[playerEntities[0].objCharacter.idxSwitchVisited].objTrigger.isOn  {
                    TriggerEntities[playerEntities[0].objCharacter.idxSwitchVisited].objTrigger.isOn = true
                    totalSwitchOn += 1
                    SoundManager.soundHelper.switchOnSFX.play()
                    updateStatueCount(count: totalSwitchOn, total: totalSwitch)
                    currStatue = childNode(withName: TriggerEntities[playerEntities[0].objCharacter.idxSwitchVisited].objTrigger.name ?? "") as! SKSpriteNode
                    currStatue.run(switchAnim)
                    
                    print("total switch on: ",totalSwitchOn)
                    if (totalSwitchOn == totalSwitch){
                        updateStatusWinning()
                        self.lift.physicsBody?.categoryBitMask = 0x100000
                                            let index = TriggerEntities.firstIndex(where: {$0.objTrigger.name == "portal"})
                                            currPortal = childNode(withName: TriggerEntities[index!].objTrigger.name!) as! SKSpriteNode
                                            currPortal.run(portalAnim)
                        SoundManager.soundHelper.elevatorOnSFX.play()
                    }
                } else if playerEntities[0].objCharacter.hidingRange && playerEntities[0].objCharacter.isMovement {
                    SoundManager.soundHelper.hideSFX.play()
                    playerEntities[0].objCharacter.isHidden = true
                    playerEntities[0].objCharacter.isMovement = false
                    enemyEntity.agent.behavior = wanderBehavior
                    run(SKAction.repeat(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.run(startCountDown)]), count: 5))
                } else if !playerEntities[0].objCharacter.isMovement {
                    playerEntities[0].component(ofType: PlayerControllerComponent.self)?.unHide()
                }
            }
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
        
    func startCountDown() {
        playerEntities[0].component(ofType: PlayerControllerComponent.self)?.countDown()
//        if !playerEntities[0].objCharacter.isHidden {
//            print("masuk pak eko")
//            addChild(playerEntities[0].objCharacter)
//        }
    }
        
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 0, 123:
            playerEntities[0].objCharacter.left = false
        case 2, 124:
            playerEntities[0].objCharacter.right = false
        case 1, 125:
            playerEntities[0].objCharacter.down = false
        case 13, 126:
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
        
        if !playerEntities[0].objCharacter.isHidden {
            enemyEntity.component(ofType: EnemyControllerComponent.self)?.makePathFinding(target: player1Entity)
        }
        
        player1Entity.objCharacter.lastPos = player1Entity.agent.position
        
        if CGPointDistance(from: enemyEntity.objCharacter.position, to: player1Entity.objCharacter.position) <= 150 && !SoundManager.soundHelper.hauntSFX.isPlaying {
            SoundManager.soundHelper.hauntSFX.play()
        }
        
        self.lastUpdateTime = currentTime
        overlayShadow.position = player1Entity.objCharacter.position
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
    
    func CGPointDistanceSquared(from: CGPoint, to: CGPoint) -> CGFloat {
        return (from.x - to.x) * (from.x - to.x) + (from.y - to.y) * (from.y - to.y)
    }
    
    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
        return sqrt(CGPointDistanceSquared(from: from, to: to))
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        let nodes = nodes(at: location)
        
        for node in nodes {
            if node.name == "returnButton" {
                returnButton.isHidden = true
                let newScene = MenuScene(size: (view?.bounds.size)!)
                newScene.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 2)
                self.view?.presentScene(newScene, transition: transition)
                break
            }
        }
    }
}
