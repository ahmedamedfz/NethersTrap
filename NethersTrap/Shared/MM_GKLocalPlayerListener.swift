//
//  RealTimeGame+GKLocalPlayerListener.swift
//  Lug-N-Loaded
//
//  Created by Abraham Putra Lukas on 23/06/23.
//

import Foundation
import GameKit
import SwiftUI

extension MatchManager: GKLocalPlayerListener {
    func player(_ player: GKPlayer, didRequestMatchWithRecipients recipientPlayers: [GKPlayer]) {
        print("\n\nSending invites to other players.")
    }

    func player(_ player: GKPlayer, didAccept invite: GKInvite) {
        if let viewController = GKMatchmakerViewController(invite: invite) {
            viewController.matchmakerDelegate = self
            rootViewController?.present(viewController, animated: true) {}
        }
    }
}
