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
    var cameraNode: SKCameraNode!
    var wallMap: SKSpriteNode!
    var triggerLamp: SKSpriteNode!
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var goLeft: Bool = false
    private var goRight: Bool = false
    private var goUp: Bool = false
    private var goDown: Bool = false
    private var characterTextures: [SKTexture] = []
    
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
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        makerPlayer()
        makeCamera()
        makeTriggerLamp()
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
        hero = SKSpriteNode(imageNamed: "Ghost_A_Down__3")
        hero.zPosition = 100
        hero.position = CGPoint(x: 0, y: 0)
        hero.setScale(0.4)
//        print(hero.size)
        hero.physicsBody = SKPhysicsBody(rectangleOf: hero.size)
        hero.physicsBody?.isDynamic = true
        hero.physicsBody?.affectedByGravity = false
        hero.physicsBody?.allowsRotation = false
        hero.physicsBody?.categoryBitMask = 0x10
//        print("x: \(0x1 << 0)")
        hero.physicsBody?.collisionBitMask = 0x1
        hero.physicsBody?.contactTestBitMask = 0x100
        
//        characterTextures.append(SKTexture(imageNamed: "dummy"))
//        let animation = SKAction.animate(with: characterTextures, timePerFrame: 0.1)
//        let animationRepeat = SKAction.repeatForever(animation)
        addChild(hero)
//        hero.run(animationRepeat)
    }
    
    func makeTriggerLamp() {
        triggerLamp = childNode(withName: "triggerLamp") as? SKSpriteNode
//        print("masuk")
//        print("trigger: \(String(describing: triggerLamp))")
        triggerLamp.physicsBody?.categoryBitMask = 0x100
        triggerLamp.physicsBody?.contactTestBitMask = 0x10
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
        
        if collision == 0x10 | 0x100 {
            print("yes")
        }
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
        case 123:
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
            
        case 124:
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
        
        case 125:
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
        case 126:
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
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 123:
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
            
        case 124:
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
        
        case 125:
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
        case 126:
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
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
//        print("dt: \(dt)")
        if goLeft {
            hero.position.x -= 40.0 * CGFloat(dt)
        }
        
        if goRight {
            hero.position.x += 40.0 * CGFloat(dt)
        }
        
        if goDown {
            hero.position.y -= 40.0 * CGFloat(dt)
        }
        
        if goUp {
            hero.position.y += 40.0 * CGFloat(dt)
        }
        
        cameraNode.position = hero.position
        
        // Update entities
//        for entity in self.entities {
//            entity.update(deltaTime: dt)
//        }
        
        self.lastUpdateTime = currentTime
    }
}
