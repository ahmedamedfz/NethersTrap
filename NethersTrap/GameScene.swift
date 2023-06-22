//
//  GameScene.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 16/06/23.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    var hero = SKSpriteNode()
    var chaser = SKSpriteNode()
    var cameraNode: SKCameraNode!
    var wallMap: SKSpriteNode!
    var triggerLamp: SKSpriteNode!
    var hit: String = ""
    var deathAnimting: Bool = false
    
    let spawnPositions: [CGPoint] = [
           CGPoint(x: 100, y: 100),
           CGPoint(x: 50, y: 50),
           CGPoint(x: 75, y: 75)
           // Add more spawn positions as needed
       ]
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var timeHiding: Int = 5
    
    
    // Up 1 Down 2 Left 3 Right 4
    private var lastMovement: Int = 2
    private var playerMovement: Bool = true
    private var goUp: Bool = false
    private var goDown: Bool = false
    private var goLeft: Bool = false
    private var goRight: Bool = false
    private var characterTextures: [SKTexture] = []
    private var isHiding: Bool = false
    
    private var characterDownTexture: [SKTexture] = []
    private var characterDown: SKAction = SKAction()
    private var characterUpTexture: [SKTexture] = []
    private var characterUp: SKAction = SKAction()
    private var characterRightTexture: [SKTexture] = []
    private var characterRight: SKAction = SKAction()
    private var characterLeftTexture: [SKTexture] = []
    private var characterLeft: SKAction = SKAction()
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        for i in 0...11 {
            characterDownTexture.append(SKTexture(imageNamed: "GhostADown/\(i)"))
        }
        characterDown = SKAction.animate(with: characterDownTexture, timePerFrame: 0.1)
        
        for i in 0...11 {
            characterUpTexture.append(SKTexture(imageNamed: "GhostAUp/\(i)"))
        }
        characterUp = SKAction.animate(with: characterUpTexture, timePerFrame: 0.1)
        
        for i in 0...11 {
            characterRightTexture.append(SKTexture(imageNamed: "GhostARight/\(i)"))
        }
        characterRight = SKAction.animate(with: characterRightTexture, timePerFrame: 0.1)
        
        for i in 0...11 {
            characterLeftTexture.append(SKTexture(imageNamed: "GhostALeft/\(i)"))
        }
        characterLeft = SKAction.animate(with: characterLeftTexture, timePerFrame: 0.1)
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        makerPlayer()
        makeChaser()
        makeCamera()
        makeTriggerLamp()
        makeTriggerHide()
        generateRandomHideSpots()
        // Example usage
//               let randomIndex = Int(arc4random_uniform(UInt32(spawnPositions.count)))
//               let randomSpawnPosition = spawnPositions[randomIndex]
//
//               // Spawn an object at the random spawn position
//               let objectNode = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
//               objectNode.position = randomSpawnPosition
//               addChild(objectNode)
        
//        makeWallMap()
//        makeColliderTileMap()
//        physicsWorld.contactDelegate = self
//        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
//        for node in self.children {
//            if node.name == "wall" {
//                if let someTileMap:SKTileMapNode = node as? SKTileMapNode {
//                    giveTileMapPhysicsBody(map: someTileMap)
//                    someTileMap.removeFromParent()
//                }
//            }
//        }
    }
    
    func makerPlayer() {
        let texture = SKTexture(imageNamed: "GhostADown/0")
        hero = SKSpriteNode(texture: texture)
        hero.run(SKAction.repeatForever(characterDown))
        hero.zPosition = 100
        hero.position = CGPoint(x: 0, y: 0)
        hero.setScale(0.4)
//        print(hero.size)
        hero.physicsBody = SKPhysicsBody(texture: texture, size: hero.size)
        hero.physicsBody?.isDynamic = true
        hero.physicsBody?.affectedByGravity = false
        hero.physicsBody?.allowsRotation = false
        hero.physicsBody?.categoryBitMask = 0x10
//        print("x: \(0x1 << 0)")
        hero.physicsBody?.collisionBitMask = 0x1
        hero.physicsBody?.contactTestBitMask = 0x100 | 0x1000
        
//        characterTextures.append(SKTexture(imageNamed: "dummy"))
//        let animation = SKAction.animate(with: characterTextures, timePerFrame: 0.1)
//        let animationRepeat = SKAction.repeatForever(animation)
        addChild(hero)
//        hero.run(animationRepeat)
    }
    
    func makeChaser() {
        let texture = SKTexture(imageNamed: "GhostADown/0")
        chaser = SKSpriteNode(texture: texture)
        chaser.run(SKAction.repeatForever(characterDown))
        chaser.zPosition = 100
        chaser.position = CGPoint(x: 0, y: 0)
        chaser.setScale(0.4)
//        print(chaser.size)
        chaser.physicsBody = SKPhysicsBody(texture: texture, size: chaser.size)
        chaser.physicsBody?.isDynamic = true
        chaser.physicsBody?.affectedByGravity = false
        chaser.physicsBody?.allowsRotation = false
        chaser.physicsBody?.categoryBitMask = 0x1000
//        print("x: \(0x1 << 0)")
        chaser.physicsBody?.collisionBitMask = 0x1
        chaser.physicsBody?.contactTestBitMask = 0x10
        addChild(chaser)
    }
    
    func makeTriggerLamp() {
        triggerLamp = childNode(withName: "triggerLamp") as? SKSpriteNode
//        print("masuk")
//        print("trigger: \(String(describing: triggerLamp))")
        triggerLamp.physicsBody?.categoryBitMask = 0x100
        triggerLamp.physicsBody?.contactTestBitMask = 0x10
    }
    
    func makeTriggerHide() {
        triggerLamp = childNode(withName: "triggerHide") as? SKSpriteNode
//        print("masuk")
//        print("trigger: \(String(describing: triggerLamp))")
        triggerLamp.physicsBody?.categoryBitMask = 0x10000
        triggerLamp.physicsBody?.contactTestBitMask = 0x10
    }
    
    func generateRandomHideSpots() {
        let hideSpotSize = CGSize(width: 20, height: 20)
        let hideSpotTexture = SKTexture(imageNamed: "hide_spot_image")
        // Example area
        
        let spawnPositions: [CGPoint] = [
               CGPoint(x: 25, y: 25),
               CGPoint(x: 50, y: 50),
               CGPoint(x: 100, y: 50),
               CGPoint(x: 50, y: 100),
               CGPoint(x: 150, y: 50),
               CGPoint(x: 50, y: 150)
               // Add more spawn positions as needed
           ]
        
        let numHideSpots = 3 // Number of hide spots to generate
        
        for _ in 0...numHideSpots {
            let randomIndex = Int(arc4random_uniform(UInt32(spawnPositions.count)))
            let hideSpotPosition = spawnPositions[randomIndex]
            
            let hideSpot = SKSpriteNode(texture: hideSpotTexture, size: hideSpotSize)
            hideSpot.position = hideSpotPosition
            hideSpot.physicsBody = SKPhysicsBody(rectangleOf: hideSpotSize)
            hideSpot.physicsBody?.isDynamic = false
            hideSpot.physicsBody?.categoryBitMask = 0x10000
            hideSpot.physicsBody?.contactTestBitMask = 0x10// Adjust according to your collision detection setup
            
            addChild(hideSpot)
        }
    }

    
    
    func makeWallMap() {
        var count = 0
        for child in children {
            if child.name == "SKSpriteNode" {
                count+=1
            }
        }
//        print(count)
    }
    
//    func makeColliderTileMap() {
//        wallMap = childNode(withName: "wall") as? SKTileMapNode
//        wallMap.physicsBody = SKPhysicsBody(edgeLoopFrom: wallMap.frame)
//        wallMap.physicsBody?.categoryBitMask = 0x1
//        wallMap.physicsBody?.collisionBitMask = 0x1
//    }
    
    func makeCamera() {
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
        
    }
    
//    func giveTileMapPhysicsBody(map: SKTileMapNode) {
//        let tileMap = map
//        let startingLocation:CGPoint = tileMap.position
//        let tileSize = tileMap.tileSize
//        print("tileSize: \(tileSize)")
//
//        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width
//        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height
//
//        print("halfwidth: \(halfWidth), halfHeight: \(halfHeight)")
//
//        for col in 0..<tileMap.numberOfColumns {
//            for row in 0..<tileMap.numberOfRows {
//                if let tileDefiniton = tileMap.tileDefinition(atColumn: col, row: row) {
//                    let tileArray = tileDefiniton.textures
//                    let tileTexture = tileArray[0]
//                    let x = CGFloat(col) * tileSize.width - halfWidth + (tileSize.width / 2)
//                    let y = CGFloat(row) * tileSize.height - halfHeight + (tileSize.height / 2)
//                    print("x: \(x), y: \(y)")
//                    let tileNode = SKSpriteNode(texture: tileTexture)
//                    tileNode.anchorPoint = CGPoint(x: 0.0001, y: 0.0001)
//                    tileNode.position = CGPoint(x: x, y: y)
//                    tileNode.physicsBody = SKPhysicsBody(texture: tileTexture, size: CGSize(width: (tileTexture.size().width), height: (tileTexture.size().height)))
//                    tileNode.physicsBody?.linearDamping = 60.0
//                    tileNode.physicsBody?.affectedByGravity = false
//                    tileNode.physicsBody?.allowsRotation = false
//                    tileNode.physicsBody?.isDynamic = false
//                    tileNode.physicsBody?.friction = 0
//
//                    self.addChild(tileNode)
//
//                    tileNode.position = CGPoint(x: tileNode.position.x + startingLocation.x, y: tileNode.position.y + startingLocation.y)
//
//                }
//            }
//        }
//    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision:UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        //        print("\(3 | 2)")
        if hit.isEmpty {
            if collision == 0x10 | 0x100 {
                print("yes")
                hit = "Switch"
                hero.isHidden = true
            }
            else if collision == 0x10 | 0x1000 && !deathAnimting {
                print("Catch")
                hit = "Catch"
                deathAnimting = true
                animateDeath()
            }
            else if collision == 0x10 | 0x10000 {
                print("hide")
                isHiding = true
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        hit = ""
        isHiding = false
        hero.isHidden = false
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 0x31:
            if let label = self.label {
                label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            }
        case 0:
            goLeft = true
//            let x: CGFloat = hero.position.x - 5.0
//            let y: CGFloat = hero.position.y + 0.0
            
//            let xTime: CGFloat = abs(x / 100)
//            let yTime: CGFloat = abs(y / 100)
            
//            print("\(xTime), \(yTime)")
            
//            let xMove = SKAction.moveTo(x: x, duration: 0.1)
//            let yMove = SKAction.moveTo(y: y, duration: 0.1)
//
//            let group = SKAction.group([xMove, yMove])
//            hero.run(group)
            
        case 2:
            goRight = true
//            let x: CGFloat = hero.position.x + 5.0
//            let y: CGFloat = hero.position.y + 0.0
            
//            let xTime: CGFloat = abs(x / 100)
//            let yTime: CGFloat = abs(y / 100)
            
//            let xMove = SKAction.moveTo(x: x, duration: 0.1)
//            let yMove = SKAction.moveTo(y: y, duration: 0.1)
//
//            let group = SKAction.group([xMove, yMove])
//            hero.run(group)
        
        case 1:
            goDown = true
//            let x: CGFloat = hero.position.x + 0.0
//            let y: CGFloat = hero.position.y - 5.0
            
//            let xTime: CGFloat = abs(x / 100)
//            let yTime: CGFloat = abs(y / 100)
            
//            let xMove = SKAction.moveTo(x: x, duration: 0.1)
//            let yMove = SKAction.moveTo(y: y, duration: 0.1)
//
//            let group = SKAction.group([xMove, yMove])
//            hero.run(group)
        case 13:
            goUp = true
//            let x: CGFloat = hero.position.x + 0.0
//            let y: CGFloat = hero.position.y + 5.0
            
//            let xTime: CGFloat = abs(x / 100)
//            let yTime: CGFloat = abs(y / 100)
            
//            let xMove = SKAction.moveTo(x: x, duration: 0.1)
//            let yMove = SKAction.moveTo(y: y, duration: 0.1)
//
//            let group = SKAction.group([xMove, yMove])
//            hero.run(group)
        case 3:
            if isHiding == true{
                hero.isHidden = true
                playerMovement = false
//                timeHiding = 5
                run(SKAction.repeat(SKAction.sequence([SKAction.wait(forDuration: 1), SKAction.run(countDown)]), count: 5)) {
                    self.timeHiding = 5
                }
//                run(SKAction.wait(forDuration: 5)) {
//                    self.hero.isHidden = false
//                    self.playerMovement = true
//                }
            }
            else{
                hero.isHidden = false
                playerMovement = true
            }
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 0:
            goLeft = false
//            let x: CGFloat = hero.position.x - 5.0
//            let y: CGFloat = hero.position.y + 0.0
            
//            let xTime: CGFloat = abs(x / 100)
//            let yTime: CGFloat = abs(y / 100)
            
//            print("\(xTime), \(yTime)")
            
//            let xMove = SKAction.moveTo(x: x, duration: 0.1)
//            let yMove = SKAction.moveTo(y: y, duration: 0.1)
//
//            let group = SKAction.group([xMove, yMove])
//            hero.run(group)
            
        case 2:
            goRight = false
//            let x: CGFloat = hero.position.x + 5.0
//            let y: CGFloat = hero.position.y + 0.0
            
//            let xTime: CGFloat = abs(x / 100)
//            let yTime: CGFloat = abs(y / 100)
            
//            let xMove = SKAction.moveTo(x: x, duration: 0.1)
//            let yMove = SKAction.moveTo(y: y, duration: 0.1)
//
//            let group = SKAction.group([xMove, yMove])
//            hero.run(group)
        
        case 1:
            goDown = false
//            let x: CGFloat = hero.position.x + 0.0
//            let y: CGFloat = hero.position.y - 5.0
            
//            let xTime: CGFloat = abs(x / 100)
//            let yTime: CGFloat = abs(y / 100)
            
//            let xMove = SKAction.moveTo(x: x, duration: 0.1)
//            let yMove = SKAction.moveTo(y: y, duration: 0.1)
//
//            let group = SKAction.group([xMove, yMove])
//            hero.run(group)
        case 13:
            goUp = false
//            let x: CGFloat = hero.position.x + 0.0
//            let y: CGFloat = hero.position.y + 5.0
            
//            let xTime: CGFloat = abs(x / 100)
//            let yTime: CGFloat = abs(y / 100)
            
//            let xMove = SKAction.moveTo(x: x, duration: 0.1)
//            let yMove = SKAction.moveTo(y: y, duration: 0.1)
//
//            let group = SKAction.group([xMove, yMove])
//            hero.run(group)
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    func animateDeath() {
        run(SKAction.wait(forDuration: 5)) {
            self.deathAnimting = false
            print("Animation Done")
        }
    }
    func countDown() {
        timeHiding -= 1
        print(timeHiding)
        if (timeHiding == 0){
            playerMovement = true
            hero.isHidden = false
            isHiding = false
            print("out")
        }
    }

    func animateMove(arrowPress: Int, movement: SKAction) {
        if arrowPress != lastMovement {
            hero.run(SKAction.repeatForever(movement))
            print("Ubah Arah")
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
//        print("dt: \(dt)")
        if playerMovement == true{
            if goUp {
                hero.position.y += 40.0 * CGFloat(dt)
                animateMove(arrowPress: 1, movement: characterUp)
                lastMovement = 1
            }
            else if goDown {
                hero.position.y -= 40.0 * CGFloat(dt)
                animateMove(arrowPress: 2, movement: characterDown)
                lastMovement = 2
            }
            else if goLeft {
                hero.position.x -= 40.0 * CGFloat(dt)
                animateMove(arrowPress: 3, movement: characterLeft)
                lastMovement = 3
            }
            else if goRight {
                hero.position.x += 40.0 * CGFloat(dt)
                animateMove(arrowPress: 4, movement: characterRight)
                lastMovement = 4
            }
        }
        
        cameraNode.position = hero.position
        
        // Update entities
//        for entity in self.entities {
//            entity.update(deltaTime: dt)
//        }
        
        self.lastUpdateTime = currentTime
    }
}
