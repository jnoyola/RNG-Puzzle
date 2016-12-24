//
//  AchievementManager.swift
//  Astro Maze
//
//  Created by Jonathan Noyola on 7/20/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import GameKit

class AchievementManager: NSObject {

    static let nameToDesc: [String: (name: String, description: String)] = [
        "star_cadet":           ("Star Cadet",           "Complete level 25"),
        "space_ranger":         ("Space Ranger",         "Complete level 50"),
        "astral_explorer":      ("Astral Explorer",      "Complete level 75"),
        "galactic_hero":        ("Galactic Hero",        "Complete level 100"),
        "void_avoider":         ("Void Avoider",         "Complete 10 puzzles without entering the Void"),
        "avid_void_avoider":    ("Avid Void Avoider",    "Complete 25 puzzles without entering the Void"),
        "valiant_void_avoider": ("Valiant Void Avoider", "Complete 50 puzzles without entering the Void"),
        "speed_racer":          ("Speed Racer",          "Complete 10 puzzles before time runs out"),
        "supersonic_racer":     ("Supersonic Racer",     "Complete 25 puzzles before time runs out"),
        "lightspeed_racer":     ("Lightspeed Racer",     "Complete 50 puzzles before time runs out"),
        "builder":              ("Builder",              "Create 10 puzzles"),
        "bold_builder":         ("Bold Builder",         "Create 10 puzzles of at least level 20"),
        "brilliant_builder":    ("Brilliant Builder",    "Create 10 puzzles of at least level 30"),
        "fan":                  ("Fan",                  "Share 10 puzzles"),
        "superfan":             ("Superfan",             "Share 25 puzzles"),
        "astrofan":             ("Astrofan",             "Share 50 puzzles"),
        "birdie":               ("Birdie",               "Share a puzzle a day for 10 days on Twitter"),
        "bookie":               ("Bookie",               "Share a puzzle a day for 10 days on Facebook"),
        "time_traveler":        ("Time Traveler",        "Travel through 100 wormholes"),
        "star_catcher":         ("Star Catcher",         "Obtain 100 stars"),
        "big_spender":          ("Big Spender",          "Spend 100 stars"),
        "collector":            ("Collector",            "Collect 10 items"),
        "the_beast":            ("The Beast",            "Complete level 6.66 in exactly 6 seconds")
    ]

    enum ShareMethod {
        case Message
        case Facebook
        case Twitter
    }
    
    static func displayAchievements(achievements: [GKAchievement], scene: SKScene) -> [AchievementPopup] {
        var popups = [AchievementPopup]()
        
        // Insert in reverse order so the bottom popup (first in loop) gets the background
        var z: CGFloat = 1000
        for achievement in achievements.reverse() {
            if achievement.percentComplete == 100 {
                let details = nameToDesc[achievement.identifier!]
                let popup = AchievementPopup(name: details!.name, description: details!.description, image: achievement.identifier!, addBackground: z == 1000, state: .Open)
                popups.append(popup)
                
                let w = scene.size.width
                let h = scene.size.height
                popup.refreshLayout(CGSize(width: w, height: h))
                popup.zPosition = z
                scene.addChild(popup)
                
                z += 1
            }
        }
        
        return popups.reverse()
    }
    
    static func makeAchievement(name: String, percent: Double) -> GKAchievement {
        let achievement = GKAchievement(identifier: name)
        achievement.percentComplete = percent * 100
        return achievement
    }

    static func recordLevelCompleted(level: LevelProtocol, duration: Int, numTimerExpirations: Int, didEnterVoid: Bool) -> [GKAchievement] {
        var achievements = [GKAchievement]()
        
        if level is Level {
        
            // Check the max level before we save this score
            let maxLevel = Storage.loadMaxLevel()
        
            var score = 1
            if numTimerExpirations == 1 || (numTimerExpirations == 0 && didEnterVoid) {
                score = 2
            } else if numTimerExpirations == 0 && !didEnterVoid {
                score = 3
            }
            Storage.saveScore(score, forLevel: level._level)
            
            if level._level == maxLevel {
                if level._level <= 25 {
                    achievements.append(makeAchievement("star_cadet", percent: Double(level._level) / 25.0))
                }
                if level._level <= 50 {
                    achievements.append(makeAchievement("space_ranger", percent: Double(level._level) / 50.0))
                }
                if level._level <= 75 {
                    achievements.append(makeAchievement("astral_explorer", percent: Double(level._level) / 75.0))
                }
                if level._level <= 100 {
                    achievements.append(makeAchievement("galactic_hero", percent: Double(level._level) / 100.0))
                }
            }
        
            if numTimerExpirations == 0 {
                let speedRacer = Storage.incProperty("speedRacer")
                
                if speedRacer <= 10 {
                    achievements.append(makeAchievement("speed_racer", percent: Double(speedRacer) / 10.0))
                }
                if speedRacer <= 25 {
                    achievements.append(makeAchievement("supersonic_racer", percent: Double(speedRacer) / 25.0))
                }
                if speedRacer <= 50 {
                    achievements.append(makeAchievement("lightspeed_racer", percent: Double(speedRacer) / 50.0))
                }
            }
            
            if !didEnterVoid {
                let voidAvoider = Storage.incProperty("voidAvoider")
                
                if voidAvoider <= 10 {
                    achievements.append(makeAchievement("void_avoider", percent: Double(voidAvoider) / 10.0))
                }
                if voidAvoider <= 25 {
                    achievements.append(makeAchievement("avid_void_avoider", percent: Double(voidAvoider) / 25.0))
                }
                if voidAvoider <= 50 {
                    achievements.append(makeAchievement("valiant_void_avoider", percent: Double(voidAvoider) / 50.0))
                }
            }
            
            if level.getCode() == "6.66" && duration == 6 {
                let theBeast = Storage.incProperty("theBeast")
                
                if theBeast == 1 {
                    achievements.append(makeAchievement("the_beast", percent: 1.0))
                }
            }
            
            if !achievements.isEmpty {
//                GKAchievement.reportAchievements(achievements, withCompletionHandler: { error in
//                    if error != nil {
//                        NSLog(error!.localizedDescription)
//                    }
//                })
            }
        }
        
        return achievements
    }
    
    static func recordWormholeTravel() {
    
    }
    
    static func recordStarsObtained(num: Int) {
    
    }
    
    static func recordStarsSpent(num: Int) {
    
    }
    
    static func recordItemPurchased() {
    
    }
    
    static func recordLevelCreated(level: LevelProtocol) {
    
    }
    
    static func recordLevelShared(level: LevelProtocol, method: ShareMethod) {
    
    }
    
    static func resetAchievements() {
        GKAchievement.resetAchievementsWithCompletionHandler({ error in
            if error != nil {
                NSLog(error!.localizedDescription)
            }
        })
        
        Storage.resetAchievements()
    }
}
