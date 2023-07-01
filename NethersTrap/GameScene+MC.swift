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
                playerNameLabel.text = player1Entity.nameEntity
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
}
