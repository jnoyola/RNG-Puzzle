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
        addLabel(nil, text: "RNG Puzzle", size: height * 0.12, color: SKColor.blueColor(), y: 0.75)
        
        // Play
        addLabel("btn_play", text: "Play", size: height * 0.064, color: SKColor.whiteColor(), y: 0.55)
        
        // Instructions
        addLabel("btn_instructions", text: "Instructions", size: height * 0.064, color: SKColor.whiteColor(), y: 0.38)
        
        // Leaderboard
        addLabel("btn_leaderboard", text: "Leaderboard", size: height * 0.064, color: SKColor.whiteColor(), y: 0.21)
        
        // iNoyola
        addLabel(nil, text: "iNoyola", size: height * 0.04, color: SKColor.grayColor(), y: 0.05)
    }
    
    func addLabel(name: String?, text: String, size: CGFloat, color: SKColor, y: CGFloat) {
        let label = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        label.text = text
        label.fontSize = size
        label.fontColor = color
        label.position = CGPointMake(self.size.width*0.5, self.size.height*y)
        if (name != nil) {
            label.name = name!
        }
        self.addChild(label)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let touchLocation = touch.locationInNode(self)
        let touchedNode = self.nodeAtPoint(touchLocation)
        if (touchedNode.name == "btn_play") {
            let levelSelectScene = LevelSelectScene(size: size)
            levelSelectScene.scaleMode = scaleMode
            view?.presentScene(levelSelectScene)
        } else if (touchedNode.name == "btn_instructions") {
            let instructionsScene = InstructionsScene(size: size)
            instructionsScene.scaleMode = scaleMode
            view?.presentScene(instructionsScene)
        } else if (touchedNode.name == "btn_leaderboard") {
            //////////
            // TODO //
            //////////
        }
    }
}