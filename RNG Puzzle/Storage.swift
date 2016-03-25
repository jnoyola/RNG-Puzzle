//
//  Storage.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 3/25/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import UIKit

class Storage: NSObject {

    static func registerDefaults() {
        NSUserDefaults.standardUserDefaults().registerDefaults([
            "level": 1,
            "coins": 3
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
}
