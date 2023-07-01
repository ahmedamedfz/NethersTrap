//
//  GameScene.swift
//  NethersTrap
//
//  Created by Yehezkiel Salvator Christanto on 16/06/23.
//

import SwiftUI
import SpriteKit
import GameplayKit
import MultipeerConnectivity
import GameKit

class GameScene: SKScene, SKPhysicsContactDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate{
    //multipeer
    var session: MCSession!
    var peerID: MCPeerID!
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    var multipeer: Bool = false
    var playerPositions: [MCPeerID: CGPoint] = [:]
    
    func setupMultipeerConnectivity() {
        // Create a peer ID using the host name of the local device
        let deviceName = Host.current().localizedName ?? ""
        peerID = MCPeerID(displayName: deviceName)

        // Create a session with the local peer ID
        session = MCSession(peer: peerID)
        session.delegate = self

        // Create a browser view controller for nearby devices
        browser = MCBrowserViewController(serviceType: "my-game", session: session)
        browser.delegate = self

        // Create an advertiser assistant to handle incoming connection requests
        assistant = MCAdvertiserAssistant(serviceType: "my-game", discoveryInfo: nil, session: session)
    }

    func startMultipeerConnectivity() {
        setupMultipeerConnectivity()

        // Start advertising and browsing for peers
        assistant.start()
        if let window = view?.window {
            window.contentViewController?.presentAsModalWindow(browser)
        }

        // Assign the correct MCPeerID to player2Entity and player3Entity
        let connectedPeers = session.connectedPeers
        if !connectedPeers.isEmpty {
            if player2Entity.spriteName.isEmpty {
                player2Entity = CharEntity(name: "GhostADown/1", role: .Player)
                addChild(player2Entity.objCharacter)
                addAgent(entityNode: player2Entity)
            } else if player3Entity.spriteName.isEmpty {
                player3Entity = CharEntity(name: "GhostADown/1", role: .Player)
                addChild(player3Entity.objCharacter)
                addAgent(entityNode: player3Entity)
            }
        }
    }
    
    func stopMultipeerConnectivity() {
        session?.disconnect()
        session = nil
        peerID = nil
        browser = nil
        assistant = nil
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected to peer: \(peerID.displayName)")
            multipeer = true
            // You can perform any necessary actions when a peer is connected
//            if player2Entity.spriteName.isEmpty {
//                player2Entity = CharEntity(name: "GhostADown/1", role: .Player)
//                addChild(player2Entity.objCharacter)
//                addAgent(entityNode: player2Entity)
//            } else if player3Entity.spriteName.isEmpty {
//                player3Entity = CharEntity(name: "GhostADown/1", role: .Player)
//                addChild(player3Entity.objCharacter)
//                addAgent(entityNode: player3Entity)
//            }
        case .connecting:
            print("Connecting to peer: \(peerID.displayName)")
        case .notConnected:
            print("Disconnected from peer: \(peerID.displayName)")
        default:
            break
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        // Process received data
               
               // Decode the received position
               guard let receivedPosition = try? NSKeyedUnarchiver.unarchivedObject(ofClass: PointWrapper.self, from: data) else {
                   print("Failed to receive data")
                   return
               }
               
               let position = receivedPosition.point
               print("Received data from \(peerID.displayName): \(position)")
               
               // Handle received data
               
//               // Check which player entity corresponds to the received peer ID
//               var playerEntity: CharEntity?
//               if peerID == player2Entity.peerID {
//                   playerEntity = player2Entity
//               } else if peerID == player3Entity.peerID {
//                   playerEntity = player3Entity
//               } else {
//                   return // Unknown peer ID
//               }
               
               // Update the position of the player entity
               player2Entity.objCharacter.position = position
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        // Called when the user finishes browsing for nearby devices
        browserViewController.dismiss(true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        // Called when the user cancels browsing for nearby devices
        browserViewController.dismiss(true)
    }
    
    // Method to update the position of a player entity and send the updated position to other peers
    
    func sendPlayerPosition(position : CGPoint) {
        // Get the position of player1Entity
        let PlayerPosition = position
        
        // Create a PointWrapper object to encode the position
        let pointWrapper = PointWrapper(point: PlayerPosition)
        
        // Convert the PointWrapper object to data
        guard let positionData = try? NSKeyedArchiver.archivedData(withRootObject: pointWrapper, requiringSecureCoding: true) else {
            return
        }
        
        // Send the position data to connected peers
        do {
            try session.send(positionData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Error sending position data: \(error.localizedDescription)")
        }
    }



    
    var characterEntities = [CharEntity]()
    var TriggerEntities = [TriggerEntity]()
    var cameraNode: SKCameraNode!
    //    var triggerLamp: SKSpriteNode!
    
    //    static public var instance: GameScene = GameScene()
    private var lastUpdateTime : TimeInterval = 0
    
    @Published var enemyEntity: CharEntity = CharEntity(name: "Enemy", role: .Enemy)
    @Published var player1Entity: CharEntity = CharEntity(name: "", role: .Player)
    @Published var player2Entity: CharEntity = CharEntity(name: "", role: .Player)
    @Published var player3Entity: CharEntity = CharEntity(name: "", role: .Player)
    @Published var player4Entity: CharEntity = CharEntity(name: "", role: .Player)
    var agents: [GKAgent2D] = []
    var chaseBehavior: GKBehavior?
    
    let playerControlComponentSystem = GKComponentSystem(componentClass: PlayerControllerComponent.self)
    
    override func sceneDidLoad() {
        self.lastUpdateTime = 0
    }
    
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        setupEntities()
        addComponentsToComponentSystems()
//        session.delegate = self
        //        authenticateLocalPlayer()
        //        let browseButton = SKLabelNode(text: "Browse")
        //        browseButton.fontSize = 20
        //        browseButton.fontColor = .white
        //        browseButton.position = CGPoint(x: size.width - 80, y: size.height - 40)
        //        browseButton.name = "browseButton"
        //        addChild(browseButton)
    }
    
    func setupEntities() {
        player1Entity = CharEntity(name: "GhostADown/0", role: .Player)
        addChild(player1Entity.objCharacter)
        addAgent(entityNode: player1Entity)
        
        enemyEntity = CharEntity(name: "GhostADown/5", role: .Enemy)
        addChild(enemyEntity.objCharacter)
        addAgent(entityNode: enemyEntity)
        
        let switchEntity = TriggerEntity(name: "Cobblestone_Grid_Center", type: .Switch)
        addChild(switchEntity.objTrigger)
        
        let hideOutEntity = TriggerEntity(name: "Water_Grid_Center", type: .HideOut)
        addChild(hideOutEntity.objTrigger)
        characterEntities = [enemyEntity, player1Entity]
        TriggerEntities = [switchEntity]
        makeCamera()
    }
    
    func makeCamera() {
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
    }
    
    func addAgent(entityNode: CharEntity) {
        let entity = entityNode.objCharacter.entity
        let agent = entityNode.agent
        
        agent.delegate = entityNode
        agent.position = SIMD2(x: Float(entityNode.objCharacter.position.x), y: Float(entityNode.objCharacter.position.y))
        entity?.addComponent(agent)
        
        if entityNode.role == .Enemy {
            chaseBehavior = GKBehavior(goal: GKGoal(toSeekAgent: player1Entity.agent), weight: 1.0)
            agent.behavior = chaseBehavior
            
            agent.mass = 0.01
            agent.maxSpeed = 50
            agent.maxAcceleration = 1000
        }
    }
    
    func addComponentsToComponentSystems() {
        for ent in characterEntities {
            playerControlComponentSystem.addComponent(foundIn: ent)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision:UInt32 = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        if characterEntities[1].objCharacter.hit.isEmpty {
            if collision == 0x10 | 0x100 {
                print("Switch")
                characterEntities[1].objCharacter.hit = "Switch"
                //                characterEntities[1].objCharacter.isHidden = true
            } else if collision == 0x10 | 0x1000 && !characterEntities[1].objCharacter.deathAnimating {
                print("Catched")
                characterEntities[1].objCharacter.hit = "Catched"
                characterEntities[1].objCharacter.deathAnimating = true
                //                animateDeath()
                for case let component as PlayerControllerComponent in playerControlComponentSystem.components {
                    component.animateDeath()
                }
            } else if collision == 0x10 | 0x10000 {
                print("Hide")
                characterEntities[1].objCharacter.hidingRange = true
            }
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        characterEntities[1].objCharacter.hit = ""
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
            if characterEntities[1].objCharacter.hidingRange {
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
                unHide()
            }
            
        case 11:
            print("multipeer")
//            authenticateLocalPlayer()
                        startMultipeerConnectivity()
        default:
            print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
        }
    }
    
    func startCountDown() {
        for case let component as PlayerControllerComponent in playerControlComponentSystem.components {
            component.countDown()
        }
    }
    
    func unHide() {
        for case let component as PlayerControllerComponent in playerControlComponentSystem.components {
            component.unHide()
        }
    }
    
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
        if multipeer == true{
            sendPlayerPosition(position: player2Entity.objCharacter.position)
        }
//        if isMultiplayerGame {
//
//            // Example: Sending game updates to the other player
//            let gameData = "success".data(using: .utf8)
//            sendDataToOtherPlayer(data: gameData!)
//            sendPlayerPosition()
//        }
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Update the position of the local player entity and send the updated position to other peers
//                updatePlayerPosition(playerEntity: player2Entity)
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        for case let component as PlayerControllerComponent in playerControlComponentSystem.components {
            component.movement(moveLeft: characterEntities[1].objCharacter.left, moveRight: characterEntities[1].objCharacter.right, moveUp: characterEntities[1].objCharacter.up, moveDown: characterEntities[1].objCharacter.down, dt: dt, camera: cameraNode, speed: characterEntities[1].objCharacter.walkSpeed, isMovement: characterEntities[1].objCharacter.isMovement)
        }
        
        // Agent Update
        player1Entity.agent.update(deltaTime: dt)
        player2Entity.agent.update(deltaTime: dt)
        enemyEntity.agent.update(deltaTime: dt)
        
        self.lastUpdateTime = currentTime
    }
}
