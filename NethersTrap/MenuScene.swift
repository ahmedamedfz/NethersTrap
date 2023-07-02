//
//  MenuScene.swift
//  NethersTrap
//
//  Created by Ahmad Fariz on 02/07/23.
//

import SpriteKit
import GameplayKit


class MenuScene: SKScene, SKPhysicsContactDelegate {
    
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
    
    let totalSwitch = 1
    var totalSwitchOn = 0
    var spawnPaintingSpots: [SKNode] = []
    var spawnTrashCanSpots: [SKNode] = []
    var spawnSwitchSpots: [SKNode] = []
    
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
        
        scene?.enumerateChildNodes(withName: "Switch") { node, _ in
            self.spawnSwitchSpots.append(node)
            node.isHidden = true
        }
        
        
        let switchEntity = TriggerEntity(name: "switchfirst", type: .Switch, spriteImage: "Statues/0", pos: CGPoint(x: -0.932, y: 15.03))
        addChild(switchEntity.objTrigger)
        TriggerEntities.append(switchEntity)
        
        let portalEntity = TriggerEntity(name: "portal", type: .Portal, spriteImage: "Elevators/0", pos: CGPoint(x: 96.519, y: 29.053))
        portalEntity.objTrigger.size = CGSize(width: 130, height: 115)
        portalEntity.objTrigger.zPosition = 2
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
        player1Entity.objCharacter.addChild(playerNameLabel)
        
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
        
        
        playerEntities = [player1Entity]
        
        makeCamera()
        
        
    }
    
    func makeCamera() {
        cameraNode = SKCameraNode()
        cameraNode.xScale = 100 / 100
        cameraNode.yScale = 100 / 100
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
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision:UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if playerEntities[0].objCharacter.hit.isEmpty {
            if collision == 0x10 | 0x100 {
                let index = TriggerEntities.firstIndex(where: {$0.objTrigger.name == contact.bodyB.node?.name})
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
                    isLose = true
                    
                    
                    playerEntities[0].component(ofType: PlayerControllerComponent.self)?.animateDeath()
                }
            } else if collision == 0x10 | 0x10000 {
                //                print("contact: ", contact.bodyA.node?.name ?? "")
                print("Hide")
                player1Entity.objCharacter.childNode(withName: "Press")?.isHidden = false
                playerEntities[0].objCharacter.hidingRange = true
            }
            else if collision == 0x10 | 0x100000 && totalSwitchOn == totalSwitch {
                //                print("contact: ", contact.bodyA.node?.name ?? "")
                playerEntities[0].objCharacter.isMovement = false
                playerEntities[0].objCharacter.isHidden = true
                let gameScene = GameScene(fileNamed: "GameScene")
                let graphic = GKScene(fileNamed: "GameScene")
                gameScene!.scaleMode = .aspectFill
                gameScene!.wanderGraph = graphic!.graphs["WanderGraph"]?.nodes as? [GKGraphNode2D]
                let transition = SKTransition.fade(withDuration: 2)
                self.view?.presentScene(gameScene!, transition: transition)
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        playerEntities[0].objCharacter.hit = ""
        playerEntities[0].objCharacter.idxSwitchVisited = -1
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
            } else if !playerEntities[0].objCharacter.isMovement {
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
        
        
        player1Entity.objCharacter.lastPos = player1Entity.agent.position
        
        
        self.lastUpdateTime = currentTime
        overlayShadow.position = player1Entity.objCharacter.position
    }
    
    
}
