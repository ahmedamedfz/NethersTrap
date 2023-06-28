//
//  MainMenu.swift
//  NethersTrap
//
//  Created by Ahmad Fariz on 28/06/23.
//

import Foundation
import SpriteKit
import GameKit

class MainMenu: SKScene, GKMatchDelegate, GKMatchmakerViewControllerDelegate, GKInviteEventListener {
    
    var match: GKMatch?
    var matchMaker: GKMatchmaker?
    var isMultiplayerGame = false
    
    override func sceneDidLoad() {
        matchMaker = GKMatchmaker.shared()
        authenticateLocalPlayer()
    }
    
    override func didMove(to view: SKView) {
    }
    
    func authenticateLocalPlayer() {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { viewController, error in
            if let viewController = viewController {
                // Present the authentication view controller if needed
                if let window = NSApplication.shared.windows.first {
                    window.contentViewController?.presentAsSheet(viewController)
                }
            }
            else if localPlayer.isAuthenticated {
                // The local player is authenticated, set up the match
                self.setupMatchmaking()
            }
            else {
                // Authentication failed, handle the error
                print("Failed to authenticate player: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    
    func setupMatchmaking() {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 4
        
        let matchmakerViewController = GKMatchmakerViewController(matchRequest: request)
        matchmakerViewController?.matchmakerDelegate = self
        
        if let window = view?.window {
            window.contentViewController?.presentAsSheet(matchmakerViewController!)
        }
    }
    
    func startMultiplayerGame() {
        // Start the game or perform any necessary setup
        // For example, you can add other players' characters to the scene
        // and synchronize the game state with other players
    }
    
    func sendGameDataToPlayers(_ data: Data) {
        guard let match = match, match.expectedPlayerCount == 0 else {
            return
        }
        
        do {
            try match.sendData(toAllPlayers: data, with: .reliable)
        } catch {
            print("Failed to send data to players: \(error.localizedDescription)")
        }
    }
    
    // MARK: InviteListener
    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        let vc = GKMatchmakerViewController(invite: invite)
        vc?.matchmakerDelegate = self
        
        if let window = view?.window {
            window.contentViewController?.presentAsSheet(vc!)
        }
    }
    
    // MARK: - GKMatchDelegate
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
    
    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        if let receivedString = String(data: data, encoding: .utf8) {
            print("Received data from player \(player.displayName): \(receivedString)")
            
            // Handle received data
        }
    }
    
    func startGame() {
        // Send game start signal to all players in the match
        let data = "START".data(using: .utf8)
        do {
            try match?.sendData(toAllPlayers: data!, with: .reliable)
        } catch {
            print("Failed to send game start signal: \(error.localizedDescription)")
        }
        
        // Implement your game logic here
    }
    
    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        // Matchmaking was cancelled
        viewController.dismiss(true)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        // Matchmaking failed
        print("Matchmaking error: \(error.localizedDescription)")
        viewController.dismiss(true)
    }
    
    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        // Match found
        self.match = match
        match.delegate = self
        isMultiplayerGame = true
        
        viewController.dismiss(true)
        
        // Start the game or perform any necessary setup
        self.startMultiplayerGame()
    }
}
