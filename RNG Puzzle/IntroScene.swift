//
//  IntroScene.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 9/24/15.
//  Copyright © 2015 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit

class IntroScene: SKScene {

    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        let height = size.height
        
        // Title
        addLabel("RNG Puzzle", size: height * 0.12, color: SKColor.blueColor(), y: 0.75)
        
        // Play
        addLabel("Play", size: height * 0.064, color: SKColor.whiteColor(), y: 0.55)
        
        // Instructions
        addLabel("Instructions", size: height * 0.064, color: SKColor.whiteColor(), y: 0.38)
        
        // Leaderboard
        addLabel("Leaderboard", size: height * 0.064, color: SKColor.whiteColor(), y: 0.21)
        
        // iNoyola
        addLabel("iNoyola", size: height * 0.04, color: SKColor.grayColor(), y: 0.05)
    }
    
    func addLabel(text: String, size: CGFloat, color: SKColor, y: CGFloat) {
        let label = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        label.text = text
        label.fontSize = size
        label.fontColor = color
        label.position = CGPointMake(self.size.width*0.5, self.size.height*y)
        self.addChild(label)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let p = touch.locationInNode(self)
        if (p.x > size.width * 0.3 && p.x < size.width * 0.7 && p.y < size.height * 0.65) {
            if (p.y > size.height * 0.48) {
                let levelSelectScene = LevelSelectScene(size: size)
                levelSelectScene.scaleMode = scaleMode
                view?.presentScene(levelSelectScene)
            } else if (p.y > size.height * 0.31) {
                let instructionsScene = InstructionsScene(size: size)
                instructionsScene.scaleMode = scaleMode
                view?.presentScene(instructionsScene)
            } else if (p.y > size.height * 0.14) {
                //////////
                // TODO //
                //////////
            }
        }
    }
}