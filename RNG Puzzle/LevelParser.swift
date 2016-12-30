//
//  LevelParser.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 4/8/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import Foundation

class LevelParser: NSObject {

    static func parse(code: String, allowGenerated: Bool = false, allowCustom: Bool = false) -> LevelProtocol? {
        var level: LevelProtocol? = nil
        
        let tokens = code.components(separatedBy: ".")
        
        // Check for non-digits
        let badCharacters = NSCharacterSet.decimalDigits.inverted
        if !tokens[0].isEmpty && tokens[0].rangeOfCharacter(from: badCharacters) == nil {
        
            // Parse level
            let levelNum = (tokens[0] as NSString).integerValue
            if levelNum > 0 {
                
                // Parse seed
                var seed: String? = nil
                if tokens.count > 1 && !tokens[1].isEmpty {
                    seed = tokens[1]
                }
                
                if allowGenerated && (seed == nil || seed!.characters.count < 5) {
                    level = Level(level: levelNum, seed: seed)
                } else if allowCustom {
                    level = CustomLevel(level: levelNum, seed: seed)
                }
            }
        }
        
        if level == nil {
            AlertManager.defaultManager().alert("Invalid level code")
        }
        return level
    }
}
