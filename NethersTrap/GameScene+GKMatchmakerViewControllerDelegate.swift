//
//  GameScene+GKMatchmakerViewControllerDelegate.swift
//  NethersTrap
//
//  Created by Eldrick Loe on 27/06/23.
//

import Foundation
import GameKit

extension GameScene: GKMatchmakerViewControllerDelegate {
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
