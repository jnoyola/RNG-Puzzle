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
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        refreshLayout()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            NSLog("Generating: \(self._level.getCode())")
            self._level.generate(false)
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
            
            dispatch_async(dispatch_get_main_queue()) {
                let playScene = PlayScene(size: self.size, level: self._level)
                playScene.scaleMode = self.scaleMode
                (UIApplication.sharedApplication().delegate! as! AppDelegate).pushViewController(SKViewController(scene: playScene), animated: true)
            }
        }
    }
    
    func addLabel(text: String, size: CGFloat, color: SKColor, y: CGFloat) {
        let label = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        label.text = text
        label.fontSize = size
        label.fontColor = color
        label.position = CGPointMake(self.size.width * 0.5, self.size.height * y)
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
        addLabel("Generating Level...", size: s * 0.08, color: SKColor.blueColor(), y: 0.85)
        
        // Level
        let levelLabel = LevelLabel(level: _level._level, seed:_level.getSeedString(), size: s * 0.08, color: SKColor.whiteColor())
        levelLabel.position = CGPointMake(w * 0.5, h * 0.67)
        addChild(levelLabel)
    }
    
    override func didChangeSize(oldSize: CGSize) {
        refreshLayout()
    }
}
