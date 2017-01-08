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

    var _level: LevelProtocol! = nil
    
    var _titleLabel: SKLabelNode! = nil
    var _levelLabel: LevelLabel! = nil
    var _starDisplay: StarDisplay! = nil

    init(size: CGSize, level: LevelProtocol) {
        super.init(size: size)
        _level = level
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        _titleLabel = addLabel("Generating...", color: Constants.TITLE_COLOR)
        
        let score = Storage.loadScore(level: _level._level)
        _starDisplay = StarDisplay(scene: self, oldScore: score, newScore: score)
        addChild(_starDisplay)
        
        refreshLayout()
        
        DispatchQueue.global(qos: .default).async {
            NSLog("Generating: \(self._level.getCode())")
            let _ = self._level.generate(debug: true)
            usleep(750000)
        
            // DEBUG CODE
//            var badLevels = [Level]()
//            for l in 1...100 {
//                NSLog("Level \(l)")
//                for i in 0...9999 {
//                    let level = Level(level: l, seed: nil)
//                    level._seed = UInt32(i)
//                    //NSLog("Generating: \(level._level).\(level._seed)")
//                    if !level.generate(debug: true) {
//                        badLevels.append(level)
//                        NSLog("Bad: \(level._level).\(level._seed) =================")
//                    }
//                }
//            }
            
            DispatchQueue.main.async {
                let playScene = PlayScene(size: self.size, level: self._level)
                playScene.scaleMode = self.scaleMode
                AppDelegate.pushViewController(SKViewController(scene: playScene), animated: true, offset: 0)
            }
        }
    }
    
    func addLabel(_ text: String, color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: Constants.FONT)
        label.text = text
        label.fontColor = color
        self.addChild(label)
        return label
    }
    
    func refreshLayout() {
        if _level == nil {
            return
        }
    
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        // Title
        _titleLabel.fontSize = s * Constants.TITLE_SCALE
        _titleLabel.position = CGPoint(x: w * 0.5, y: h * 0.85)
        
        // Level
        if _levelLabel != nil {
            _levelLabel.removeFromParent()
        }
        _levelLabel = LevelLabel(level: _level._level, seed:_level.getSeedString(), size: s * Constants.TEXT_SCALE, color: SKColor.white)
        _levelLabel.position = CGPoint(x: w * 0.5, y: h * 0.67)
        addChild(_levelLabel)
        
        // Stars
        _starDisplay.position = CGPoint(x: w * 0.5, y: h * 0.36 - s * 0.21)
        _starDisplay.setSize(s * 0.2)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        refreshLayout()
    }
}
