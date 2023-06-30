//
//  RealTimeGame+MatchData.swift
//  Lug-N-Loaded
//
//  Created by Abraham Putra Lukas on 23/06/23.
//

import Foundation
import GameKit
import SwiftUI

extension MatchManager {
    func encode(positionX: Double) -> Data? {
        let sharedItem = SharedItem(itemId: 0, positionX: positionX, positionY: 0.0, inLuggage: false, itemRotation: 0, inPlayer1: false, inPlayer2: false)
        return encode(sharedItem: sharedItem)
    }

    func encode(positionY: Double) -> Data? {
        let sharedItem = SharedItem(itemId: 0, positionX: 0.0, positionY: positionY, inLuggage: false, itemRotation: 0, inPlayer1: false, inPlayer2: false)
        return encode(sharedItem: sharedItem)
    }

    func encode(inLuggage: Bool) -> Data? {
        let sharedItem = SharedItem(itemId: 0, positionX: 0.0, positionY: 0.0, inLuggage: inLuggage, itemRotation: 0, inPlayer1: false, inPlayer2: false)
        return encode(sharedItem: sharedItem)
    }

    func encode(inPlayer1: Bool) -> Data? {
        let sharedItem = SharedItem(itemId: 0, positionX: 0.0, positionY: 0.0, inLuggage: false, itemRotation: 0, inPlayer1: inPlayer1, inPlayer2: false)
        return encode(sharedItem: sharedItem)
    }

    func encode(inPlayer2: Bool) -> Data? {
        let sharedItem = SharedItem(itemId: 0, positionX: 0.0, positionY: 0.0, inLuggage: false, itemRotation: 0, inPlayer1: false, inPlayer2: inPlayer2)
        return encode(sharedItem: sharedItem)
    }

    func encode(itemId: Int) -> Data? {
        let sharedItem = SharedItem(itemId: itemId, positionX: 0.0, positionY: 0.0, inLuggage: false, itemRotation: 0, inPlayer1: false, inPlayer2: false)
        return encode(sharedItem: sharedItem)
    }

    func encode(itemRotation: Int) -> Data? {
        let sharedItem = SharedItem(itemId: 0, positionX: 0.0, positionY: 0.0, inLuggage: false, itemRotation: itemRotation, inPlayer1: false, inPlayer2: false)
        return encode(sharedItem: sharedItem)
    }

    func encode(sharedItem: SharedItem) -> Data? {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml

        do {
            let data = try encoder.encode(sharedItem)
            return data
        } catch {
            print("Error: \(error.localizedDescription).")
            return nil
        }
    }

    func decode(sharedItem: Data) -> SharedItem? {
        // Convert the data object to a game data object.
        return try? PropertyListDecoder().decode(SharedItem.self, from: sharedItem)
    }
}
