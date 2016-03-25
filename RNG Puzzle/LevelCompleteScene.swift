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
    var _titleLabel: SKLabelNode! = nil
    var _copyLabel: SKLabelNode! = nil
    var _quitLabel: SKLabelNode! = nil
    var _continueLabel: SKLabelNode! = nil
    var _levelLabel: LevelLabel! = nil
    var _messagesButton: SKSpriteNode! = nil
    var _facebookButton: SKSpriteNode! = nil
    var _twitterButton: SKSpriteNode! = nil

    init(size: CGSize, level: Level) {
        super.init(size: size)
        _level = level
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        // Title
        _titleLabel = addLabel("Level Complete!", color: SKColor.blueColor())
        
        // Copy Level ID
        _copyLabel = addLabel("Copy Level ID", color: SKColor.grayColor())
        
        // Quit
        _quitLabel = addLabel("Quit", color: SKColor.whiteColor())
        
        // Resume
        _continueLabel = addLabel("Continue", color: SKColor.whiteColor())
        
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
        
        
        let w = size.width
        let h = size.height
        
        if p.x > w * 0.25 && p.x < w * 0.75 && p.y > h * 0.55 && p.y < h * 0.79 {
            // Copy Level ID
            UIPasteboard.generalPasteboard().string = _level.getCode()
            _copyLabel.text = "Level ID Copied"
        } else if isPointInBounds(p, node: _quitLabel) {
            // Quit
            presentScene(IntroScene(size: size))
        } else if isPointInBounds(p, node: _continueLabel) {
            // Continue
            let nextLevel = Level()
            nextLevel._level = _level._level + 1
            presentScene(LevelGenerationScene(size: size, level: nextLevel))
        } else if isPointInBounds(p, node: _facebookButton) {
            notify("shareFacebook")
        } else if isPointInBounds(p, node: _messagesButton) {
            notify("shareMessages")
        } else if isPointInBounds(p, node: _twitterButton) {
            notify("shareTwitter")
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
        scene.scaleMode = scaleMode
        view?.presentScene(scene)
    }
    
    func notify(name: String) {
        // TODO add level code to notification
        NSNotificationCenter.defaultCenter().postNotificationName(name, object: self)
    }
    
    func refreshLayout() {
        if _level == nil {
            return
        }
    
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        _titleLabel.fontSize = s * 0.08
        _titleLabel.position = CGPoint(x: w * 0.5, y: h * 0.85)
        
        _copyLabel.fontSize = s * 0.04
        _copyLabel.position = CGPoint(x: w * 0.5, y: h * 0.67 - s * 0.05)
        
        _quitLabel.fontSize = s * 0.064
        _quitLabel.position = CGPoint(x: w * 0.15, y: h * 0.47)
        
        _continueLabel.fontSize = s * 0.064
        _continueLabel.position = CGPoint(x: w * 0.85, y: h * 0.47)
        
        _messagesButton.size = CGSize(width: s * 0.15, height: s * 0.15)
        _messagesButton.position = CGPoint(x: w * 0.5 - s * 0.25, y: h * 0.28)
        
        _facebookButton.size = CGSize(width: s * 0.15, height: s * 0.15)
        _facebookButton.position = CGPoint(x: w * 0.5, y: h * 0.28)
        
        _twitterButton.size = CGSize(width: s * 0.15, height: s * 0.15)
        _twitterButton.position = CGPoint(x: w * 0.5 + s * 0.25, y: h * 0.28)
        
        if _levelLabel != nil {
            _levelLabel.removeFromParent()
        }
        _levelLabel = LevelLabel(level: _level._level, seed:_level._seed, size: s * 0.08, color: SKColor.whiteColor())
        _levelLabel.position = CGPoint(x: w * 0.5, y: h * 0.67)
        self.addChild(_levelLabel)
        
    }
    
    override func didChangeSize(oldSize: CGSize) {
        refreshLayout()
    }
}
