//
//  Storage.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 3/25/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import Foundation

class Storage: NSObject {

    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            "scores": [NSNumber](),
            "stars": 3,
            "customNames": [NSString](),
            "customCodes": [NSString](),
            "voidAvoider": 0,
            "speedRacer": 0,
            "builder": 0,
            "fan": 0,
            "birdie": 0,
            "bookie": 0,
            "timeTraveler": 0,
            "starCatcher": 0,
            "bigSpender": 0,
            "collector": 0,
            "theBeast": 0,
            "isMuted": false
        ])
    }
    
    static func loadScores() -> [NSNumber] {
        return UserDefaults.standard.object(forKey: "scores") as! [NSNumber]
    }
    
    static func loadScore(level: Int) -> Int {
        let scores = loadScores()
        
        if level <= scores.count {
            return Int(scores[level - 1])
        } else if level == scores.count + 1 {
            return 0
        }
        return -1
    }

    static func loadMaxLevel() -> Int {
        return loadScores().count + 1
    }
    
    static func saveScore(_ score: Int, forLevel level: Int) {
        var scores = loadScores()
        
        if level <= scores.count {
            scores[level - 1] = score as NSNumber
        } else {
            scores.append(score as NSNumber)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "maxLevelChanged"), object: nil)
        }
        
        UserDefaults.standard.set(scores, forKey: "scores")
    }
    
    static func loadStars() -> Int {
        return UserDefaults.standard.integer(forKey: "stars")
    }

    static func addStars(_ amt: Int) {
        let stars = loadStars() + amt
        UserDefaults.standard.set(stars, forKey: "stars")
    }
    
    static func loadCustomLevelNames() -> [NSString] {
        return UserDefaults.standard.object(forKey: "customNames") as! [NSString]
    }
    
    static func loadCustomLevelCode(index: Int) -> NSString {
        return (UserDefaults.standard.object(forKey: "customCodes") as! [NSString])[index]
    }
    
    static func saveCustomLevel(_ level: LevelProtocol, name: String) {
        var names = loadCustomLevelNames()
        var codes = UserDefaults.standard.object(forKey: "customCodes") as! [NSString]
        
        names.append(name as NSString)
        codes.append(level.getCode() as NSString)
        
        UserDefaults.standard.set(names, forKey: "customNames")
        UserDefaults.standard.set(codes, forKey: "customCodes")
    }
    
    static func editCustomLevel(_ level: LevelProtocol, name: String, index: Int) {
        var names = loadCustomLevelNames()
        var codes = UserDefaults.standard.object(forKey: "customCodes") as! [NSString]
        
        names[index] = name as NSString
        codes[index] = level.getCode() as NSString
        
        UserDefaults.standard.set(names, forKey: "customNames")
        UserDefaults.standard.set(codes, forKey: "customCodes")
    }
    
    static func deleteCustomLevel(index: Int) {
        var names = loadCustomLevelNames()
        var codes = UserDefaults.standard.object(forKey: "customCodes") as! [NSString]
        
        names.remove(at: index)
        codes.remove(at: index)
        
        UserDefaults.standard.set(names, forKey: "customNames")
        UserDefaults.standard.set(codes, forKey: "customCodes")
    }
    
    static func incProperty(_ key: String, amount: Int = 1) -> Int {
        var newAmount = UserDefaults.standard.integer(forKey: key)
        newAmount += amount
        
        UserDefaults.standard.set(newAmount, forKey: key)
        
        return newAmount
    }
    
    static func resetAchievements() {
        UserDefaults.standard.set(0, forKey: "voidAvoider")
        UserDefaults.standard.set(0, forKey: "speedRacer")
        UserDefaults.standard.set(0, forKey: "builder")
        UserDefaults.standard.set(0, forKey: "fan")
        UserDefaults.standard.set(0, forKey: "birdie")
        UserDefaults.standard.set(0, forKey: "bookie")
        UserDefaults.standard.set(0, forKey: "timeTraveler")
        UserDefaults.standard.set(0, forKey: "starCatcher")
        UserDefaults.standard.set(0, forKey: "bigSpender")
        UserDefaults.standard.set(0, forKey: "collector")
        UserDefaults.standard.set(0, forKey: "theBeast")
    }
    
    static func isMuted() -> Bool {
        return UserDefaults.standard.bool(forKey: "isMuted")
    }
    
    static func toggleMute() -> Bool {
        let newIsMuted = !isMuted()
        UserDefaults.standard.set(newIsMuted, forKey: "isMuted")
        return newIsMuted
    }
}
