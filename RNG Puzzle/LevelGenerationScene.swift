//
//  LevelGenerationScene.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 9/24/15.
//  Copyright © 2015 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit

class LevelGenerationScene: SKScene {

    var _level: Level! = nil

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
        addLabel("Generating Level...", size: height * 0.08, color: SKColor.blueColor(), y: 0.85)
        
        // Level
        let levelLabel = LevelLabel(level: _level._level, seed:_level._seed, size: height * 0.08, color: SKColor.whiteColor())
        levelLabel.position = CGPointMake(self.size.width*0.5, self.size.height*0.5)
        self.addChild(levelLabel)
        
        NSTimer.scheduledTimerWithTimeInterval(0, target: self, selector: Selector("generate"), userInfo: nil, repeats: false)
    }
    
    func generate() {
        _level.generate()

        let playScene = PlayScene(size: size, level: _level)
        playScene.scaleMode = scaleMode
        view?.presentScene(playScene)
    }
    
    func addLabel(text: String, size: CGFloat, color: SKColor, y: CGFloat) {
        let label = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        label.text = text
        label.fontSize = size
        label.fontColor = color
        label.position = CGPointMake(self.size.width*0.5, self.size.height*y)
        self.addChild(label)
    }
}
