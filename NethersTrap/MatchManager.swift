////
////  MatchManager.swift
////  NethersTrap
////
////  Created by Eldrick Loe on 27/06/23.
////
//
//import Foundation
//import SwiftUI
//import GameKit
////import UIKit
//
//enum PlayerAuthState: String{
//    case authenticating = "Logging in to Game Center"
//    case unauthenticated = "Please Sign in to Game Center"
//    case aunthenticaed = ""
//    case error = "There was an error logging into Game Center"
//    case restricted = "You're not allowed to play multiplayer game! "
//}
//
//class MatchManager: ObservableObject{
//    @Published var inGame = false
//    @Published var isGameOver = false
//    @Published var authenticationState = PlayerAuthState.authenticating
//
//    var match: GKMatch?
//    var otherPlayer: GKPlayer?
//    var hostPlayer = GKLocalPlayer.local
//    var playerUUID = UUID().uuidString
//
//    var rootViewController: UIViewController?{
//        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowSccene
//        return windowScene?,window.first?.rootViewController
//    }
//    
//    
//}
