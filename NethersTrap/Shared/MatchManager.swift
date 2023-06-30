//
//  MatchManager.swift
//  Lug-N-Loaded
//
//  Created by Kevin Bryan on 29/06/23.
//

import Foundation
import GameKit
import SwiftUI

/// - Tag:RealTimeGame
@MainActor
class MatchManager: NSObject, GKGameCenterControllerDelegate, ObservableObject {
    public static var shared = MatchManager()

    // The game interface state.
    @Published var matchAvailable = false
    @Published var playingGame = false
    @Published var myMatch: GKMatch? = nil
    @Published var automatch = false

    // The match information.
    @Published var myAvatar = Image(systemName: "person.crop.circle")
    @Published var opponentAvatar = Image(systemName: "person.crop.circle")
    @Published var opponent: GKPlayer? = nil

    @Published var player1: String = ""
    @Published var player2: String = ""
    @Published var currentLevel: Int = 1

    @Published var scene: GameScene?
    @Published var remainingTime: Int = 0

    var currentPlayer: String {
        GKLocalPlayer.local.gamePlayerID
    }

//    var rootViewController: UIViewController? {
//        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
//        return windowScene?.windows.first?.rootViewController
//    }

    // MARK: CORE MULTIPLAYER FUNCTIONALITY

    func sendItemData(item: ItemNode, player: String) {
        let positionX = Double(item.position.x)
        let positionY = Double(item.position.y)


        do {
            let sharedItem = SharedItem(
                itemId: item.itemId,
                positionX: positionX,
                positionY: positionY,
                inLuggage: item.inLuggage,
                itemRotation: 0,
                inPlayer1: player == player1,
                inPlayer2: player == player2
            )
            let encodedSharedItem = encode(sharedItem: sharedItem)
            try myMatch?.sendData(toAllPlayers: encodedSharedItem!, with: GKMatch.SendDataMode.unreliable)
        } catch {
            print("ERROR: \(error.localizedDescription)")
        }
    }

    func receiveData(gameScene: GameScene, sharedItem: SharedItem) {
        print("dapet dataaa")
        print("\(sharedItem)")

        let item = GameSceneFunctions.findNode(gameScene: gameScene, itemId: sharedItem.itemId)
        let newPosition = CGPoint(x: sharedItem.positionX, y: sharedItem.positionY)

        if sharedItem.inPlayer1 {
            item.lastTouchedBy = player1 // TODO: set berdasarkan player1 id
        } else {
            item.lastTouchedBy = player2 // TODO: set berdasarkan player2 id
        }

        if sharedItem.inLuggage {
            GameSceneFunctions.prepareImpact(
                gameScene: gameScene,
                item: item,
                newLocation: newPosition
            )

        } else {
            returnToLastToucher(gameScene: gameScene, item: item)
        }
    }

    func returnToPlayer1(gameScene: GameScene, item: ItemNode) {
        if gameScene.isPlayer1 {
            // move item outside, and teleport back to inventory using prepareImpact
            let dummyPosition = CGPoint(x: -1000, y: -1000)
            GameSceneFunctions.prepareImpact(gameScene: gameScene, item: item, newLocation: dummyPosition)
        } else {
            hideItem(item: item)
        }
    }

    func returnToPlayer2(gameScene: GameScene, item: ItemNode) {
        if gameScene.isPlayer2 {
            // move item outside, and teleport back to inventory using prepareImpact
            let dummyPosition = CGPoint(x: -1000, y: -1000)
            GameSceneFunctions.prepareImpact(gameScene: gameScene, item: item, newLocation: dummyPosition)
        } else {
            hideItem(item: item)
        }
    }

    func returnToLastToucher(gameScene: GameScene, item: ItemNode) {
        if item.lastTouchedBy == player1 {
            if gameScene.isPlayer1 == true {
                let dummyPosition = CGPoint(x: -1000, y: -1000)
                GameSceneFunctions.prepareImpact(gameScene: gameScene, item: item, newLocation: dummyPosition)
            } else {
                hideItem(item: item)
            }
        } else {
            if gameScene.isPlayer2 == true {
                let dummyPosition = CGPoint(x: -1000, y: -1000)
                GameSceneFunctions.prepareImpact(gameScene: gameScene, item: item, newLocation: dummyPosition)
            } else {
                hideItem(item: item)
            }
        }
    }

    func hideItem(item: ItemNode) {
        item.zPosition = -10000
        item.position = CGPoint(x: 10000, y: 10000)
    }

    // MARK: GK TEMPLATES FUNCTIONS

    func authenticatePlayer() {
        GKLocalPlayer.local.authenticateHandler = { viewController, error in
            if let viewController = viewController {
                self.rootViewController?.present(viewController, animated: true) {}
                return
            }
            if let error {
                print("Error: \(error.localizedDescription).")
                return
            }

            GKLocalPlayer.local.loadPhoto(for: GKPlayer.PhotoSize.small) { image, error in
                if let image {
                    self.myAvatar = Image(uiImage: image)
                }
                if let error {
                    print("Error: \(error.localizedDescription).")
                }
            }

            GKLocalPlayer.local.register(self)
            GKAccessPoint.shared.location = .topLeading
            GKAccessPoint.shared.showHighlights = true
            GKAccessPoint.shared.isActive = true
            self.matchAvailable = true
        }
    }

    func findPlayer() async {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        let match: GKMatch
        do {
            match = try await GKMatchmaker.shared().findMatch(for: request)
        } catch {
            print("Error: \(error.localizedDescription).")
            return
        }
        if !playingGame {
            startMyMatchWith(match: match)
        }
        GKMatchmaker.shared().finishMatchmaking(for: match)
        automatch = false
    }

    func choosePlayer() {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2
        if let viewController = GKMatchmakerViewController(matchRequest: request) {
            viewController.matchmakerDelegate = self
            rootViewController?.present(viewController, animated: true) {}
        }
    }

    func startMyMatchWith(match: GKMatch) {
        GKAccessPoint.shared.isActive = false
        playingGame = true
        myMatch = match
        myMatch?.delegate = self

        if myMatch?.expectedPlayerCount == 0 {
            opponent = myMatch?.players[0]
            opponent?.loadPhoto(for: GKPlayer.PhotoSize.small) { image, error in
                if let image {
                    self.opponentAvatar = Image(uiImage: image)
                }
                if let error {
                    print("Error: \(error.localizedDescription).")
                }
            }
        }

        var hasSetPlayer1 = false
        if hasSetPlayer1 == false {
            // Make sure Player 1 and Player 2 is the same for both players!
            player1 = GKLocalPlayer.local.gamePlayerID
            player2 = opponent?.gamePlayerID ?? ""
            hasSetPlayer1.toggle()
        }
        reportProgress()
    }

    func endMatch() {}

    func forfeitMatch() {}

    func saveScore() {
        GKLeaderboard.submitScore(remainingTime, context: 0, player: GKLocalPlayer.local,
                                  leaderboardIDs: ["123"])
        { error in
            if let error {
                print("Error: \(error.localizedDescription).")
            }
        }
    }

    func resetMatch() {
        playingGame = false
        myMatch?.disconnect()
        myMatch?.delegate = nil
        myMatch = nil
        opponent = nil
        opponentAvatar = Image(systemName: "person.crop.circle")
        GKAccessPoint.shared.isActive = true
    }

    // Rewarding players with achievements.
    func reportProgress() {
        GKAchievement.loadAchievements(completionHandler: { (achievements: [GKAchievement]?, error: Error?) in
            let achievementID = "1234"
            var achievement: GKAchievement?

            // Find an existing achievement.
            achievement = achievements?.first(where: { $0.identifier == achievementID })

            // Otherwise, create a new achievement.
            if achievement == nil {
                achievement = GKAchievement(identifier: achievementID)
            }

            // Create an array containing the achievement.
            let achievementsToReport: [GKAchievement] = [achievement!]

            // Set the progress for the achievement.
            achievement?.percentComplete = achievement!.percentComplete + 10.0

            // Report the progress to Game Center.
            GKAchievement.report(achievementsToReport, withCompletionHandler: { (error: Error?) in
                if let error {
                    print("Error: \(error.localizedDescription).")
                }
            })

            if let error {
                print("Error: \(error.localizedDescription).")
            }
        })
    }
}
