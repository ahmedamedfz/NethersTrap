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
    
    
    lazy var bgmPlayer: AVAudioPlayer! = {
        do {
            guard let ambienceSound = Bundle.main.url(forResource: "ambience", withExtension: "mp3") else {
                return nil
            }
            let player = try AVAudioPlayer(contentsOf: ambienceSound)
            player.numberOfLoops = -1
            player.volume = 1
            return player
        }
        catch {
            print(error)
            return nil
        }
    }()
    
    lazy var killedSFX: AVAudioPlayer! = {
        do {
            guard let killedSound = Bundle.main.url(forResource: "died", withExtension: "mp3") else {
                return nil
            }
            let player = try AVAudioPlayer(contentsOf: killedSound)
            player.volume = 1
            return player
        }
        catch {
            print(error)
            return nil
        }
    }()
    
    lazy var elevatorOnSFX: AVAudioPlayer! = {
        do {
            guard let elevatorOnSound = Bundle.main.url(forResource: "elevator", withExtension: "mp3") else {
                return nil
            }
            let player = try AVAudioPlayer(contentsOf: elevatorOnSound)
            player.volume = 0.5
            return player
        }
        catch {
            print(error)
            return nil
        }
    }()
    
    lazy var hauntSFX: AVAudioPlayer! = {
        do {
            guard let hauntSound = Bundle.main.url(forResource: "haunt", withExtension: "mp3") else {
                return nil
            }
            let player = try AVAudioPlayer(contentsOf: hauntSound)
            player.volume = 1
            return player
        }
        catch {
            print(error)
            return nil
        }
    }()
    
    lazy var hideSFX: AVAudioPlayer! = {
        do {
            guard let hideSound = Bundle.main.url(forResource: "hide", withExtension: "mp3") else {
                return nil
            }
            let player = try AVAudioPlayer(contentsOf: hideSound)
            player.volume = 0.5
            return player
        }
        catch {
            print(error)
            return nil
        }
    }()
    
    lazy var switchOnSFX: AVAudioPlayer! = {
        do {
            guard let switchOnSound = Bundle.main.url(forResource: "switch", withExtension: "mp3") else {
                return nil
            }
            let player = try AVAudioPlayer(contentsOf: switchOnSound)
            player.volume = 0.5
            return player
        }
        catch {
            print(error)
            return nil
        }
    }()
    
    lazy var unhideSFX: AVAudioPlayer! = {
        do {
            guard let unhideSound = Bundle.main.url(forResource: "unhide", withExtension: "mp3") else {
                return nil
            }
            let player = try AVAudioPlayer(contentsOf: unhideSound)
            player.volume = 0.5
            return player
        }
        catch {
            print(error)
            return nil
        }
    }()
    
    lazy var winSFX: AVAudioPlayer! = {
        do {
            guard let unhideSound = Bundle.main.url(forResource: "win", withExtension: "mp3") else {
                return nil
            }
            let player = try AVAudioPlayer(contentsOf: unhideSound)
            player.volume = 0.5
            return player
        }
        catch {
            print(error)
            return nil
        }
    }()
}
