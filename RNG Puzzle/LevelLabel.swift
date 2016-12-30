//
//  LevelLabel.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 3/19/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit

class LevelLabel: SKNode {
    
    init(level: Int, seed: String, size: CGFloat, color: SKColor) {
        super.init()
        
        let levelLabel = SKLabelNode(fontNamed: Constants.FONT)
        levelLabel.text = "Level \(level)"
        levelLabel.fontSize = size
        levelLabel.fontColor = color
        levelLabel.horizontalAlignmentMode = .center
        
        let seedLabel = SKLabelNode(fontNamed: Constants.FONT)
        seedLabel.text = ".\(seed)"
        seedLabel.fontSize = size * 0.7
        seedLabel.fontColor = color
        seedLabel.horizontalAlignmentMode = .center
        
        levelLabel.position = CGPoint(x: -seedLabel.frame.size.width / 2, y: 0)
        seedLabel.position = CGPoint(x: levelLabel.frame.size.width / 2, y: 0)
        
        addChild(levelLabel)
        addChild(seedLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
