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
        let tokens = code.componentsSeparatedByString(".")
        
        // Parse level
        // TODO check if non-digit before decimal
        let levelNum = max(1, (tokens[0] as NSString).integerValue)
        
        // Parse seed
        var seed: String? = nil
        if tokens.count > 1 && !tokens[1].isEmpty {
            seed = tokens[1]
        }
        
        var level: LevelProtocol? = nil
        if allowGenerated && (seed == nil || seed!.characters.count < 5) {
            level = Level(level: levelNum, seed: seed)
        } else if allowCustom {
            level = CustomLevel(level: levelNum, seed: seed)
        }
        
        if level == nil {
            AlertManager.defaultManager().alert("Invalid level code")
        }
        return level
    }
}
