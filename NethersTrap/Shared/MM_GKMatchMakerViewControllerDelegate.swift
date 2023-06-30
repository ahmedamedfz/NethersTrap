//
//  RealTimeGame+GKMatchmakerViewControllerDelegate.swift
//  Lug-N-Loaded
//
//  Created by Abraham Putra Lukas on 23/06/23.
//

import Foundation
import GameKit
import SwiftUI

extension MatchManager: GKMatchmakerViewControllerDelegate {
    func matchmakerViewController(_ viewController: GKMatchmakerViewController,
                                  didFind match: GKMatch)
    {
        viewController.dismiss(animated: true) {}

        if !playingGame && match.expectedPlayerCount == 0 {
            startMyMatchWith(match: match)
        }
    }

    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        viewController.dismiss(animated: true)
    }

    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        print("\n\nMatchmaker view controller fails with error: \(error.localizedDescription)")
    }
}
