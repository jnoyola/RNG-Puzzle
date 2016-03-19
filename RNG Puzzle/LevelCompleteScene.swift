//
//  LevelCompleteScene.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 9/24/15.
//  Copyright © 2015 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit

class LevelCompleteScene: SKScene {

    var _level: Level! = nil
    var _copyLabel: SKLabelNode! = nil

    init(size: CGSize, level: Level) {
        super.init(size: size)
        _level = level
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        let height = size.height
        
        // Title
        addLabel("Level Complete!", size: height * 0.08, color: SKColor.blueColor(), x: 0.5, y: 0.85)
        
        // Level
        let levelLabel = LevelLabel(level: _level._level, seed:_level._seed, size: height * 0.08, color: SKColor.whiteColor())
        levelLabel.position = CGPointMake(self.size.width*0.5, self.size.height*0.5)
        self.addChild(levelLabel)
        
        // Quit
        addLabel("Quit", size: height * 0.064, color: SKColor.whiteColor(), x: 0.15, y: 0.5)
        
        // Continue
        addLabel("Continue", size: height * 0.064, color: SKColor.whiteColor(), x: 0.85, y: 0.5)
        
        // Copy Level ID
        _copyLabel = addLabel("Copy Level ID", size: height * 0.04, color: SKColor.grayColor(), x: 0.5, y: 0.45)
    }
    
    func addLabel(text: String, size: CGFloat, color: SKColor, x: CGFloat, y: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        label.text = text
        label.fontSize = size
        label.fontColor = color
        label.position = CGPointMake(self.size.width*x, self.size.height*y)
        self.addChild(label)
        return label
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let p = touch.locationInNode(self)
        if (p.y > size.height * 0.35 && p.y < size.height * 0.65) {
            if (p.x < size.width * 0.25) {
                // Quit
                let introScene = IntroScene(size: size)
                introScene.scaleMode = scaleMode
                view?.presentScene(introScene)
            } else if (p.x > size.width * 0.75) {
                // Continue
                let nextLevel = Level()
                nextLevel._level = _level._level + 1
                let levelGenerationScene = LevelGenerationScene(size: size, level: nextLevel)
                levelGenerationScene.scaleMode = scaleMode
                view?.presentScene(levelGenerationScene)
            } else {
                // Copy Level ID
                UIPasteboard.generalPasteboard().string = _level.getCode()
                _copyLabel.text = "Level ID Copied"
            }
        }
    }
}
