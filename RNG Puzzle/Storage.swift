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
        NSUserDefaults.standardUserDefaults().registerDefaults([
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
        return NSUserDefaults.standardUserDefaults().objectForKey("scores") as! [NSNumber]
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
    
    static func saveScore(score: NSNumber, forLevel level: Int) {
        var scores = loadScores()
        
        if level <= scores.count {
            scores[level - 1] = score
        } else {
            scores.append(score)
            NSNotificationCenter.defaultCenter().postNotificationName("maxLevelChanged", object: nil)
        }
        
        NSUserDefaults.standardUserDefaults().setObject(scores, forKey: "scores")
    }
    
    static func loadStars() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey("stars")
    }

    static func addStars(amt: Int) {
        let stars = loadStars() + amt
        NSUserDefaults.standardUserDefaults().setInteger(stars, forKey: "stars")
    }
    
    static func loadCustomLevelNames() -> [NSString] {
        return NSUserDefaults.standardUserDefaults().objectForKey("customNames") as! [NSString]
    }
    
    static func loadCustomLevelCode(index: Int) -> NSString {
        return (NSUserDefaults.standardUserDefaults().objectForKey("customCodes") as! [NSString])[index]
    }
    
    static func saveCustomLevel(level: LevelProtocol, name: String) {
        var names = loadCustomLevelNames()
        var codes = NSUserDefaults.standardUserDefaults().objectForKey("customCodes") as! [NSString]
        
        names.append(name)
        codes.append(level.getCode())
        
        NSUserDefaults.standardUserDefaults().setObject(names, forKey: "customNames")
        NSUserDefaults.standardUserDefaults().setObject(codes, forKey: "customCodes")
    }
    
    static func editCustomLevel(level: LevelProtocol, name: String, index: Int) {
        var names = loadCustomLevelNames()
        var codes = NSUserDefaults.standardUserDefaults().objectForKey("customCodes") as! [NSString]
        
        names[index] = name
        codes[index] = level.getCode()
        
        NSUserDefaults.standardUserDefaults().setObject(names, forKey: "customNames")
        NSUserDefaults.standardUserDefaults().setObject(codes, forKey: "customCodes")
    }
    
    static func deleteCustomLevel(index: Int) {
        var names = loadCustomLevelNames()
        var codes = NSUserDefaults.standardUserDefaults().objectForKey("customCodes") as! [NSString]
        
        names.removeAtIndex(index)
        codes.removeAtIndex(index)
        
        NSUserDefaults.standardUserDefaults().setObject(names, forKey: "customNames")
        NSUserDefaults.standardUserDefaults().setObject(codes, forKey: "customCodes")
    }
    
    static func incProperty(key: String, amount: Int = 1) -> Int {
        var newAmount = NSUserDefaults.standardUserDefaults().integerForKey(key)
        newAmount += amount
        
        NSUserDefaults.standardUserDefaults().setInteger(newAmount, forKey: key)
        
        return newAmount
    }
    
    static func resetAchievements() {
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "voidAvoider")
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "speedRacer")
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "builder")
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "fan")
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "birdie")
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "bookie")
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "timeTraveler")
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "starCatcher")
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "bigSpender")
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "collector")
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: "theBeast")
    }
    
    static func isMuted() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("isMuted")
    }
    
    static func toggleMute() -> Bool {
        let newIsMuted = !isMuted()
        NSUserDefaults.standardUserDefaults().setBool(newIsMuted, forKey: "isMuted")
        return newIsMuted
    }
}
