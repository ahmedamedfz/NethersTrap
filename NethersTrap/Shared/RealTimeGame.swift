//
//  GameManager.swift
//  NethersTrap
//
//  Created by Ahmad Fariz on 30/06/23.
//

import Foundation
import GameKit
import SpriteKit
import SwiftUI

@MainActor
class RealTimeGame: NSObject, GKGameCenterControllerDelegate, ObservableObject {
    
    public static var shared = RealTimeGame()
    
    // The local player's friends, if they grant access.
    @Published var friends: [Friend] = []
    
    // The game interface state.
    @Published var matchAvailable = false
    @Published var playingGame = false
    @Published var myMatch: GKMatch? = nil
    @Published var automatch = false
    
    // Outcomes of the game for notifing players.
    @Published var youForfeit = false
    @Published var opponentForfeit = false
    @Published var youWon = false
    @Published var opponentWon = false
    
    // The match information.
    @Published var myAvatar = Image(systemName: "person.crop.circle")
    @Published var opponentAvatar = Image(systemName: "person.crop.circle")
    @Published var opponent: GKPlayer? = nil
    @Published var myScore = 0
    @Published var opponentScore = 0
    
    /// The name of the match.
    var matchName: String {
        "\(opponentName) Match"
    }
    
    /// The local player's name.
    var myName: String {
        GKLocalPlayer.local.displayName
    }
    
    /// The opponent's name.
    var opponentName: String {
        opponent?.displayName ?? "Invitation Pending"
    }
    
    /// The root view controller of the window.
    var rootViewController: NSViewController? {
        return NSApplication.shared.mainWindow?.contentViewController
    }


    /// Authenticates the local player, initiates a multiplayer game, and adds the access point.
    /// - Tag:authenticatePlayer
    func authenticatePlayer() {
        // Set the authentication handler that GameKit invokes.
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController = viewController {
                // If the view controller is non-nil, present it to the player so they can
                // perform some necessary action to complete authentication.
                self.rootViewController?.present(viewController, animator: true as! NSViewControllerPresentationAnimator)
                return
            }
            if let error {
                // If you can’t authenticate the player, disable Game Center features in your game.
                print("Error: \(error.localizedDescription).")
                return
            }
            
            // A value of nil for viewController indicates successful authentication, and you can access
            // local player properties.
            
            // Load the local player's avatar.
            GKLocalPlayer.local.loadPhoto(for: GKPlayer.PhotoSize.small) { image, error in
                if let image {
                    self.myAvatar = Image(nsImage: image)
                }
                if let error {
                    // Handle an error if it occurs.
                    print("Error: \(error.localizedDescription).")
                }
            }

            // Register for real-time invitations from other players.
            GKLocalPlayer.local.register(self)
            
            // Add an access point to the interface.
            GKAccessPoint.shared.location = .topLeading
            GKAccessPoint.shared.showHighlights = true
            GKAccessPoint.shared.isActive = true
            
            // Enable the Start Game button.
            self.matchAvailable = true
        }
    }
    
    /// Starts the matchmaking process where GameKit finds a player for the match.
    /// - Tag:findPlayer
    func findPlayer() async {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        let match: GKMatch
        
        // Start automatch.
        do {
            match = try await GKMatchmaker.shared().findMatch(for: request)
        } catch {
            print("Error: \(error.localizedDescription).")
            return
        }

        // Start the game, although the automatch player hasn't connected yet.
        if !playingGame {
            startMyMatchWith(match: match)
        }

        // Stop automatch.
        GKMatchmaker.shared().finishMatchmaking(for: match)
        automatch = false
    }
    
    /// Presents the matchmaker interface where the local player selects and sends an invitation to another player.
    /// - Tag:choosePlayer
    func choosePlayer() {
        // Create a match request.
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        
        // Present the interface where the player selects opponents and starts the game.
        if let viewController = GKMatchmakerViewController(matchRequest: request) {
            viewController.matchmakerDelegate = self
            
            let dialogController = GKDialogController.shared()
                dialogController.parentWindow = NSApplication.shared.mainWindow
                dialogController.present(viewController)
        }
    }
    
    // Starting and stopping the game.
    
    /// Starts a match.
    /// - Parameter match: The object that represents the real-time match.
    /// - Tag:startMyMatchWith
    func startMyMatchWith(match: GKMatch) {
        GKAccessPoint.shared.isActive = false
        playingGame = true
        myMatch = match
        myMatch?.delegate = self
        
        // For automatch, check whether the opponent connected to the match before loading the avatar.
        if myMatch?.expectedPlayerCount == 0 {
            opponent = myMatch?.players[0]
            
            // Load the opponent's avatar.
            opponent?.loadPhoto(for: GKPlayer.PhotoSize.small) { (image, error) in
                if let image {
                    self.opponentAvatar = Image(nsImage: image)
                }
                if let error {
                    print("Error: \(error.localizedDescription).")
                }
            }
        }
    }
    
    /// Takes the player's turn.
    /// - Tag:takeAction
    func takeAction() {
        
    }
    
    /// Quits a match and saves the game data.
    /// - Tag:endMatch
    func endMatch() {
        //var isAllPlayerDie:[Bool] = [false,false]
        
    }
    
    /// Forfeits a match without saving the score.
    /// - Tag:forfeitMatch
    func forfeitMatch() {
    }
    
    /// Saves the local player's score.
    /// - Tag:saveScore
    func saveScore() {
    }
    
    /// Resets a match after players reach an outcome or cancel the game.
    func resetMatch() {
        // Reset the game data.
        playingGame = false
        myMatch?.disconnect()
        myMatch?.delegate = nil
        myMatch = nil
        opponent = nil
        GKAccessPoint.shared.isActive = true
        youForfeit = false
        opponentForfeit = false
        youWon = false
        opponentWon = false
    }
    
    // Rewarding players with achievements.
    
    /// Reports the local player's progress toward an achievement.
    func reportProgress() {
            }
}


