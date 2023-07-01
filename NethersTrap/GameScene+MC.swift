//
//  GameScene+MC.swift
//  NethersTrap
//
//  Created by Eldrick Loe on 01/07/23.
//

import Foundation
import SwiftUI
import SpriteKit
import GameplayKit
import MultipeerConnectivity
import GameKit

extension GameScene: MCSessionDelegate, MCBrowserViewControllerDelegate{
    //multipeer
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected to peer: \(peerID.displayName)")
            multipeer = true
            //    You can perform any necessary actions when a peer is connected
            if player2Entity.nameEntity.isEmpty {
                player2Entity = PlayerEntity(name: "\(peerID.displayName)", role: "Player", spriteImage: "GhostADown/0")
                let playerNameLabel = SKLabelNode(fontNamed: "VT323-Regular")
                playerNameLabel.text = player2Entity.nameEntity
                playerNameLabel.fontSize = 10
                playerNameLabel.fontColor = SKColor.green
                playerNameLabel.horizontalAlignmentMode = .center
                playerNameLabel.position = CGPoint(x: player2Entity.objCharacter.position.x, y: player2Entity.objCharacter.position.y + player2Entity.objCharacter.size.height/2)
                player2Entity.objCharacter.addChild(playerNameLabel)
                addChild(player2Entity.objCharacter)
                //                addAgent(entityNode: player2Entity)
            }
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
        do {
            guard let receivedPosition = try NSKeyedUnarchiver.unarchivedObject(ofClass: PointWrapper.self, from: data) else {
                print("Failed to receive data")
                return
            }
            // Process the receivedPosition object
            let position = receivedPosition.point
            print("Received data from \(peerID.displayName): \(position)")
            
            // Update the position of the player entity
            player2Entity.objCharacter.position = position
            updateAnimation(player2: player2Entity)
        } catch {
            print("Error unarchiving data: \(error)")
        }
        
        
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
    func sendPlayerPosition(position: CGPoint) {
        // Create a wrapper object to send the position data
        let positionWrapper = PointWrapper(point: position)
        
        // Convert the wrapper object to data
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: positionWrapper, requiringSecureCoding: false) else {
            print("Failed to convert position data")
            return
        }
        
        // Send the data to all connected peers
        do {
            try session.send(data, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Failed to send position data")
        }
    }
    
    func updateAnimation(player2: PlayerEntity){
        
        let playerDownTexture: [SKTexture] = [
            SKTexture(imageNamed: "GhostADown/0"),
            SKTexture(imageNamed: "GhostADown/1"),
            SKTexture(imageNamed: "GhostADown/2"),
            SKTexture(imageNamed: "GhostADown/3"),
            SKTexture(imageNamed: "GhostADown/4"),
            SKTexture(imageNamed: "GhostADown/5"),
            SKTexture(imageNamed: "GhostADown/6"),
            SKTexture(imageNamed: "GhostADown/7"),
            SKTexture(imageNamed: "GhostADown/8"),
            SKTexture(imageNamed: "GhostADown/9"),
            SKTexture(imageNamed: "GhostADown/10"),
            SKTexture(imageNamed: "GhostADown/11")
        ]
        let playerDown: SKAction = SKAction.animate(with: playerDownTexture, timePerFrame: 0.1)
        let playerUpTexture: [SKTexture] = [
            SKTexture(imageNamed: "GhostALeft/0"),
            SKTexture(imageNamed: "GhostALeft/1"),
            SKTexture(imageNamed: "GhostALeft/2"),
            SKTexture(imageNamed: "GhostALeft/3"),
            SKTexture(imageNamed: "GhostALeft/4"),
            SKTexture(imageNamed: "GhostALeft/5"),
            SKTexture(imageNamed: "GhostALeft/6"),
            SKTexture(imageNamed: "GhostALeft/7"),
            SKTexture(imageNamed: "GhostALeft/8"),
            SKTexture(imageNamed: "GhostALeft/9"),
            SKTexture(imageNamed: "GhostALeft/10"),
            SKTexture(imageNamed: "GhostALeft/11")
        ]
        let playerUp: SKAction = SKAction.animate(with: playerUpTexture, timePerFrame: 0.1)
        let playerRightTexture: [SKTexture] = [
            SKTexture(imageNamed: "GhostARight/0"),
            SKTexture(imageNamed: "GhostARight/1"),
            SKTexture(imageNamed: "GhostARight/2"),
            SKTexture(imageNamed: "GhostARight/3"),
            SKTexture(imageNamed: "GhostARight/4"),
            SKTexture(imageNamed: "GhostARight/5"),
            SKTexture(imageNamed: "GhostARight/6"),
            SKTexture(imageNamed: "GhostARight/7"),
            SKTexture(imageNamed: "GhostARight/8"),
            SKTexture(imageNamed: "GhostARight/9"),
            SKTexture(imageNamed: "GhostARight/10"),
            SKTexture(imageNamed: "GhostARight/11")
        ]
        
        let playerRight: SKAction = SKAction.animate(with: playerRightTexture, timePerFrame: 0.075)
        let playerLeftTexture: [SKTexture] = [
            SKTexture(imageNamed: "GhostAUp/0"),
            SKTexture(imageNamed: "GhostAUp/1"),
            SKTexture(imageNamed: "GhostAUp/2"),
            SKTexture(imageNamed: "GhostAUp/3"),
            SKTexture(imageNamed: "GhostAUp/4"),
            SKTexture(imageNamed: "GhostAUp/5"),
            SKTexture(imageNamed: "GhostAUp/6"),
            SKTexture(imageNamed: "GhostAUp/7"),
            SKTexture(imageNamed: "GhostAUp/8"),
            SKTexture(imageNamed: "GhostAUp/9"),
            SKTexture(imageNamed: "GhostAUp/10"),
            SKTexture(imageNamed: "GhostAUp/11")
        ]
        let playerLeft: SKAction = SKAction.animate(with: playerLeftTexture, timePerFrame: 0.075)
        
        var lastMovement: lastMove = .none
        
        let direction = player2.agent.position - player2.objCharacter.lastPos
        
        if direction.x > 0 {
            if lastMovement != .right {
                player2.objCharacter.run(SKAction.repeatForever(playerRight))
                lastMovement = .right
            }
        } else if direction.x == 0 {
        } else {
            if lastMovement != .left {
                player2.objCharacter.run(SKAction.repeatForever(playerLeft))
                lastMovement = .left
            }
        }
        
        if direction.y > 0 {
            if lastMovement != .up {
                player2.objCharacter.run(SKAction.repeatForever(playerUp))
                lastMovement = .up
            }
        } else if direction.y == 0 {
        } else {
            if lastMovement != .down {
                player2.objCharacter.run(SKAction.repeatForever(playerDown))
                lastMovement = .down
            }
        }
    }
}
