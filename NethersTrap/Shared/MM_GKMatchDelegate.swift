//
//  RealTimeGame+GKMatchDelegate.swift
//  Lug-N-Loaded
//
//  Created by Abraham Putra Lukas on 23/06/23.
//

import Foundation
import GameKit
import SwiftUI

extension MatchManager: GKMatchDelegate {
    // MARK: RECEIVE DATA

    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        if let gameData = decode(sharedItem: data) {
            print(gameData)
            self.receiveData(gameScene: scene!, sharedItem: gameData)
        }
    }

    func match(_ match: GKMatch, player: GKPlayer, didChange state: GKPlayerConnectionState) {
        switch state {
        case .connected:
            print("\(player.displayName) Connected")

            if match.expectedPlayerCount == 0 {
                opponent = match.players[0]
                opponent?.loadPhoto(for: GKPlayer.PhotoSize.small) { image, error in
                    if let image {
                        self.opponentAvatar = Image(uiImage: image)
                    }
                    if let error {
                        print("Error: \(error.localizedDescription).")
                    }
                }
            }
        case .disconnected:
            print("\(player.displayName) Disconnected")
        default:
            print("\(player.displayName) Connection Unknown")
        }
    }

    func getPlayer2Id(from match: GKMatch, localPlayer: GKPlayer) -> String? {
        if match.players.count == 2 {
            if let opponentPlayer = match.players.first(where: { $0 != localPlayer }) {
                return opponentPlayer.gamePlayerID
            }
        }
        return nil
    }

    /// Handles an error during the matchmaking process.
    func match(_ match: GKMatch, didFailWithError error: Error?) {
        print("\n\nMatch object fails with error: \(error!.localizedDescription)")
    }

    /// Reinvites a player when they disconnect from the match.
    func match(_ match: GKMatch, shouldReinviteDisconnectedPlayer player: GKPlayer) -> Bool {
        return false
    }
}
