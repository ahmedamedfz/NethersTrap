/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An extension for real-time games that handles local player listener events.
*/

import Foundation
import GameKit
import SwiftUI

extension RealTimeGame: GKLocalPlayerListener {
    /// Handles when the local player sends requests to start a match with other players.
    func player(_ player: GKPlayer, didRequestMatchWithRecipients recipientPlayers: [GKPlayer]) {
        print("\n\nSending invites to other players.")
    }
    
    /// Presents the matchmaker interface when the local player accepts an invitation from another player.
    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        // Present the matchmaker view controller in the invitation state.
        if let window = NSApplication.shared.mainWindow,
           let viewController = GKMatchmakerViewController(invite: invite) {
            viewController.matchmakerDelegate = self
            window.contentViewController?.presentAsModalWindow(viewController)
        }
    }
}

