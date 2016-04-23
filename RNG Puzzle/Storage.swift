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
            "level": 1,
            "coins": 3,
            "customNames": [NSString](),
            "customCodes": [NSString]()
        ])
    }

    static func loadLevel() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey("level")
    }
    
    static func incLevel() {
        let level = loadLevel() + 1
        NSUserDefaults.standardUserDefaults().setInteger(level, forKey: "level")
    }
    
    static func loadCoins() -> Int {
        return NSUserDefaults.standardUserDefaults().integerForKey("coins")
    }

    static func addCoins(amt: Int) {
        let coins = loadCoins() + amt
        NSUserDefaults.standardUserDefaults().setInteger(coins, forKey: "coins")
    }
    
    static func loadCustomLevelNames() -> [NSString] {
        return NSUserDefaults.standardUserDefaults().objectForKey("customNames") as! [NSString]
    }
    
    static func loadCustomLevelCode(i: Int) -> NSString {
        return (NSUserDefaults.standardUserDefaults().objectForKey("customCodes") as! [NSString])[i]
    }
    
    static func saveCustomLevel(level: LevelProtocol, name: String) {
        var names = loadCustomLevelNames()
        var codes = NSUserDefaults.standardUserDefaults().objectForKey("customCodes") as! [NSString]
        
        names.append(name)
        codes.append(level.getCode())
        
        NSUserDefaults.standardUserDefaults().setObject(names, forKey: "customNames")
        NSUserDefaults.standardUserDefaults().setObject(codes, forKey: "customCodes")
    }
}
