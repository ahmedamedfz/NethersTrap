//
//  GameScene+GKMatchDelegate.swift
//  NethersTrap
//
//  Created by Eldrick Loe on 29/06/23.
//

import Foundation
import GameKit

extension GameScene: GKMatchDelegate{
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        if let receivedString = String(data: data, encoding: .utf8) {
            print("Received data from player \(player.displayName): \(receivedString)")
            
            // Process received player position data
              if let positionData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: CGFloat] {
                  let playerX = positionData["x"] ?? 0.0
                  let playerY = positionData["y"] ?? 0.0
                  
                  // Update the position of the corresponding player entity
                  // You need to find the correct player entity based on the player identifier or other identifying information
                  // For example:
                  player2Entity.objCharacter.position = CGPoint(x: playerX, y: playerY)
              }
        }
        
    }
    
    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        switch state {
        case .connected:
            print("Player connected: \(player.displayName)")
        case .disconnected:
            print("Player disconnected: \(player.displayName)")
        default:
            break
        }
    }
    
    func sendDataToOtherPlayer(data: Data) {
        do {
            try match?.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            print("Failed to send data: \(error.localizedDescription)")
        }
    }
}
