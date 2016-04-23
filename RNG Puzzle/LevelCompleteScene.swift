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

    var _level: LevelProtocol! = nil
    var _timerCount = 0
    var _duration = 0
    
    var _titleLabel: SKLabelNode! = nil
    var _copyLabel: SKLabelNode! = nil
    var _quitLabel: SKLabelNode! = nil
    var _continueLabel: SKLabelNode! = nil
    var _levelLabel: LevelLabel! = nil
//    var _timerLabel: SKLabelNode! = nil
    var _durationLabel: SKLabelNode! = nil
    var _messagesButton: SKSpriteNode! = nil
    var _facebookButton: SKSpriteNode! = nil
    var _twitterButton: SKSpriteNode! = nil

    init(size: CGSize, level: LevelProtocol, timerCount: Int, duration: Int) {
        super.init(size: size)
        _level = level
        _timerCount = timerCount
        _duration = duration
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        // Title
        if _timerCount > 0 {
            _titleLabel = addLabel("Level Complete!", color: SKColor.blueColor())
        } else {
            _titleLabel = addLabel("Too Slow", color: SKColor.redColor())
        }
        
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
            (UIApplication.sharedApplication().delegate!.window!!.rootViewController! as! UINavigationController).popToRootViewControllerAnimated(true)
        } else if isPointInBounds(p, node: _continueLabel) {
            // Continue
            // Don't advance level past the stored max (in case we completed a CustomLevel)
            var nextLevelNum = _level._level
            if _timerCount > 0 && nextLevelNum < Storage.loadLevel() {
                ++nextLevelNum
            }
            let nextLevel = Level(level: nextLevelNum, seed: nil)
            presentScene(LevelGenerationScene(size: size, level: nextLevel))
        } else if isPointInBounds(p, node: _facebookButton) {
            // TODO add level code to sharing
            AlertManager.defaultManager().shareFacebook()
        } else if isPointInBounds(p, node: _messagesButton) {
            // TODO add level code to sharing
            AlertManager.defaultManager().shareMessages()
        } else if isPointInBounds(p, node: _twitterButton) {
            // TODO add level code to sharing
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
        (UIApplication.sharedApplication().delegate! as! AppDelegate).pushViewController(SKViewController(scene: scene), animated: true)
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
        _levelLabel = LevelLabel(level: _level._level, seed:_level.getSeedString(), size: s * 0.08, color: SKColor.whiteColor())
        _levelLabel.position = CGPoint(x: w * 0.5, y: h * 0.67)
        self.addChild(_levelLabel)
        
        refreshTimer()
    }
    
    func refreshTimer() {
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
//        if _timerLabel != nil {
//            _timerLabel.removeFromParent()
//        }
//        _timerLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
//        _timerLabel.horizontalAlignmentMode = .Left
//        _timerLabel.fontColor = UIColor.whiteColor()
//        _timerLabel.fontSize = s * 0.064
//        _timerLabel.position = CGPoint(x: w - s * 0.18, y: h - s * 0.1)
        
        if _durationLabel != nil {
            _durationLabel.removeFromParent()
        }
        _durationLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        _durationLabel.fontColor = UIColor.whiteColor()
        _durationLabel.fontSize = s * 0.1
        _durationLabel.position = CGPoint(x: w * 0.5, y: h * 0.47)
        
        updateTimerLabels()
//        addChild(_timerLabel)
        addChild(_durationLabel)
    }
    
    func updateTimerLabels() {
//        var timeStr = String(format:"%d:%02d", abs(_timerCount) / 60, abs(_timerCount) % 60)
        let durationStr = String(format:"%d:%02d", abs(_duration) / 60, abs(_duration) % 60)
//        if _timerCount < 0 {
//            timeStr = "-" + timeStr
//        }
//        _timerLabel.text = timeStr
        _durationLabel.text = durationStr
        if _timerCount <= 0 {
//            _timerLabel.fontColor = UIColor.redColor()
            _durationLabel.fontColor = UIColor.redColor()
        }
    }
    
    override func didChangeSize(oldSize: CGSize) {
        refreshLayout()
    }
}
