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

    init(size: CGSize, level: LevelProtocol) {
        super.init(size: size)
        _level = level
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        refreshLayout()
        
        DispatchQueue.global(qos: .default).async {
            NSLog("Generating: \(self._level.getCode())")
            let _ = self._level.generate(debug: false)
            usleep(500000)
        
//             DEBUG CODE
//            for l in 1...50 {
//                for i in 0...9999 {
//                    let level = Level()
//                    level._level = l
//                    level._seed = UInt32(i)
//                    NSLog("Generating: \(level._level).\(level._seed)")
//                    if !level.generate(true) {
//                        _level = level
//                        break
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
    
    func addLabel(_ text: String, size: CGFloat, color: SKColor, y: CGFloat) {
        let label = SKLabelNode(fontNamed: Constants.FONT)
        label.text = text
        label.fontSize = size
        label.fontColor = color
        label.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * y)
        self.addChild(label)
    }
    
    func refreshLayout() {
        if _level == nil {
            return
        }
    
        removeAllChildren()
    
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        // Title
        addLabel("Generating...", size: s * Constants.TITLE_SCALE, color: Constants.TITLE_COLOR, y: 0.85)
        
        // Level
        let levelLabel = LevelLabel(level: _level._level, seed:_level.getSeedString(), size: s * Constants.TEXT_SCALE, color: SKColor.white)
        levelLabel.position = CGPoint(x: w * 0.5, y: h * 0.67)
        addChild(levelLabel)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        refreshLayout()
    }
}
