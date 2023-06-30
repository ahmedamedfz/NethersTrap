//
//  SoundManager.swift
//  NethersTrap
//
//  Created by Ronald Sumichael Sunan on 30/06/23.
//

import Foundation
import AVFoundation

class SoundManager {
    static var soundHelper = SoundManager()
    
    lazy var audioPlayer: AVAudioPlayer! = {
        do {
            guard let ambienceSound = Bundle.main.url(forResource: "ambience", withExtension: "mp3") else {
                return nil
            }
            let player = try AVAudioPlayer(contentsOf: ambienceSound)
            player.numberOfLoops = -1
            player.volume = 1.5
            return player
        }
        catch {
            print(error)
            return nil
        }
    }()
    
    lazy var sfxPlayer: AVAudioPlayer! = {
        do {
            guard let ambienceSound = Bundle.main.url(forResource: "enemyHaunt", withExtension: "mp3") else {
                return nil
            }
            let player = try AVAudioPlayer(contentsOf: ambienceSound)
            player.volume = 1
            return player
        }
        catch {
            print(error)
            return nil
        }
    }()
}
