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

    var _titleLabel: SKLabelNode! = nil
    var _playLabel: SKLabelNode! = nil
    var _myLevelsLabel: SKLabelNode! = nil
    var _instructionsLabel: SKLabelNode! = nil
    var _leaderboardLabel: SKLabelNode! = nil
    var _messagesButton: SKSpriteNode! = nil
    var _facebookButton: SKSpriteNode! = nil
    var _twitterButton: SKSpriteNode! = nil

    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        // Title
        _titleLabel = addLabel("AI Puzzle", color: SKColor.blueColor())
        
        // Play
        _playLabel = addLabel("Play", color: SKColor.whiteColor())
        
        // My Puzzles
        _myLevelsLabel = addLabel("My Puzzles", color: SKColor.whiteColor())
        
        // Instructions
        _instructionsLabel = addLabel("Instructions", color: SKColor.whiteColor())
        
        // Leaderboard
        _leaderboardLabel = addLabel("Leaderboard", color: SKColor.whiteColor())

        // Social
        _messagesButton = SKSpriteNode(imageNamed: "icon_messages")
        _facebookButton = SKSpriteNode(imageNamed: "icon_facebook")
        _twitterButton = SKSpriteNode(imageNamed: "icon_twitter")
        addChild(_messagesButton)
        addChild(_facebookButton)
        addChild(_twitterButton)

        refreshLayout()
    }
    
    func addLabel(text: String, color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        label.text = text
        label.fontColor = color
        self.addChild(label)
        return label
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let p = touch.locationInNode(self)
        
        if isPointInBounds(p, node: _playLabel) {
            presentScene(LevelSelectScene())
        } else if isPointInBounds(p, node: _myLevelsLabel) {
            (UIApplication.sharedApplication().delegate!.window!!.rootViewController! as! UINavigationController).pushViewController(MyPuzzlesController(), animated: true)
        } else if isPointInBounds(p, node: _instructionsLabel) {
            presentScene(InstructionsScene())
        } else if isPointInBounds(p, node: _leaderboardLabel) {
            ///////////////////////
            // TODO: Leaderboard //
            ///////////////////////
        } else if isPointInBounds(p, node: _facebookButton) {
            AlertManager.defaultManager().shareFacebook()
        } else if isPointInBounds(p, node: _messagesButton) {
            AlertManager.defaultManager().shareMessages()
        } else if isPointInBounds(p, node: _twitterButton) {
            AlertManager.defaultManager().shareTwitter()
        }
    }
    
    func isPointInBounds(p: CGPoint, node: SKNode) -> Bool {
        let x1 = node.frame.minX - 30
        let x2 = node.frame.maxX + 30
        let y1 = node.frame.minY - 30
        let y2 = node.frame.maxY + 30
        if p.x > x1 && p.x < x2 && p.y > y1 && p.y < y2 {
            return true
        }
        return false
    }
    
    func presentScene(scene: SKScene) {
        (UIApplication.sharedApplication().delegate!.window!!.rootViewController! as! UINavigationController).pushViewController(SKViewController(scene: scene), animated: true)
    }
    
    func refreshLayout() {
        if _titleLabel == nil {
            return
        }
    
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        _titleLabel.fontSize = s * 0.12
        _titleLabel.position = CGPoint(x: w * 0.5, y: h * 0.85)
        
        _playLabel.fontSize = s * 0.064
        _playLabel.position = CGPoint(x: w * 0.5, y: h * 0.7)
        
        _myLevelsLabel.fontSize = s * 0.064
        _myLevelsLabel.position = CGPoint(x: w * 0.5, y: h * 0.55)
        
        _instructionsLabel.fontSize = s * 0.064
        _instructionsLabel.position = CGPoint(x: w * 0.5, y: h * 0.4)
        
        _leaderboardLabel.fontSize = s * 0.064
        _leaderboardLabel.position = CGPoint(x: w * 0.5, y: h * 0.25)
        
        _messagesButton.size = CGSize(width: s * 0.15, height: s * 0.15)
        _messagesButton.position = CGPoint(x: w * 0.5 - s * 0.25, y: h * 0.08)
        
        _facebookButton.size = CGSize(width: s * 0.15, height: s * 0.15)
        _facebookButton.position = CGPoint(x: w * 0.5, y: h * 0.08)
        
        _twitterButton.size = CGSize(width: s * 0.15, height: s * 0.15)
        _twitterButton.position = CGPoint(x: w * 0.5 + s * 0.25, y: h * 0.08)
    }
    
    override func didChangeSize(oldSize: CGSize) {
        refreshLayout()
    }
}