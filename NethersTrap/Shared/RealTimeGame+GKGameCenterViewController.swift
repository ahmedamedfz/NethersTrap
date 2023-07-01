//
//  MatchManagerViewController.swift
//  NethersTrap
//
//  Created by Ahmad Fariz on 30/06/23.
//

import Foundation
import GameKit
import SwiftUI

extension RealTimeGame {
    
    /// Presents the local player's achievement in the dashboard.
    func showProgress() {
        let viewController = GKGameCenterViewController(achievementID: "1234")
        viewController.gameCenterDelegate = self
        
        let dialogController = GKDialogController.shared()
            dialogController.parentWindow = NSApplication.shared.mainWindow
            dialogController.present(viewController)
    }
    
    /// Presents the top score on the leaderboard in the dashboard.
    /// - Tag:topScore
    func topScore() {
        let viewController = GKGameCenterViewController(leaderboardID: "123", playerScope: GKLeaderboard.PlayerScope.global,
                                                        timeScope: GKLeaderboard.TimeScope.allTime)
        let dialogController = GKDialogController.shared()
            dialogController.parentWindow = NSApplication.shared.mainWindow
            dialogController.present(viewController)
    }
    
    /// Cleans up the view's state when the local player closes the dashboard.
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        // Dismiss the view controller.
        let dialogController = GKDialogController.shared()
            dialogController.dismiss(self)
    }
}
