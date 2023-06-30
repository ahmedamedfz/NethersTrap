/*
See LICENSE folder for this sample’s licensing information.

Abstract:
An extension for real-time games that handles access to the local player's friends.
*/

import Foundation
import GameKit
import SwiftUI

/// A message that one player sends to another.
struct Friend: Identifiable {
    var id = UUID()
    var player: GKPlayer
}

extension RealTimeGame {
    /// Presents the friends request view controller.
    /// - Tag:addFriends
    func addFriends() {
        if let window = NSApplication.shared.mainWindow {
            do {
                try GKLocalPlayer.local.presentFriendRequestCreator(from: window)
            } catch {
                print("Error: \(error.localizedDescription).")
            }
        }
    }

    
    /// Attempts to access the local player's friends if they grant permission.
    /// - Tag:accessFriends
    func accessFriends() async {
        do {
            let authorizationStatus = try await GKLocalPlayer.local.loadFriendsAuthorizationStatus()
            
            // Creates an array of identifiable friend objects for SwiftUI.
            let loadFriendsClosure: ([GKPlayer]) -> Void = { [self] players in
                for player in players {
                    let friend = Friend(player: player)
                    friends.append(friend)
                }
            }
            
            // Handle the friend's authorization status.
            switch authorizationStatus {
            case .notDetermined:
                // The local player hasn't denied or authorized access to their friends.
                
                // Ask the local player for permission to access their friends list.
                // This may present a system prompt that might pause the game.
                let players = try await GKLocalPlayer.local.loadFriends()
                loadFriendsClosure(players)
            case .denied:
                // The local player denies access their friends.
                print("authorizationStatus: denied")
            case .restricted:
                // The local player has restrictions on sharing their friends.
                print("authorizationStatus: restricted")
            case .authorized:
                // The local player authorizes your app's request to access their friends.
    
                // Load the local player's friends.
                let players = try await GKLocalPlayer.local.loadFriends()
                loadFriendsClosure(players)
            @unknown default:
                print("authorizationStatus: unknown")
            }
        } catch {
            print("Error: \(error.localizedDescription).")
        }
    }
}
