//
//  LevelCompleteScene.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 9/24/15.
//  Copyright © 2015 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class LevelCompleteScene: SKScene {

    var _level: LevelProtocol! = nil
    var _timerCount = 0
    var _duration = 0
    var _oldScore = 0
    var _newScore = 0
    var _achievements: [GKAchievement]! = nil
    
    var _titleLabel: SKMultilineLabel! = nil
    var _copyLabel: SKLabelNode! = nil
    var _quitLabel: SKLabelNode! = nil
    var _continueLabel: SKLabelNode! = nil
    var _levelLabel: LevelLabel! = nil
    var _durationLabel: SKLabelNode! = nil
    var _starLabel: StarLabel! = nil
    var _starDisplay: StarDisplay! = nil
    var _muteShareDisplay: MuteShareDisplay! = nil
    
    var _achievementPopups: [AchievementPopup]! = nil

    init(size: CGSize, level: LevelProtocol, timerCount: Int, duration: Int, achievements: [GKAchievement], oldScore: Int, newScore: Int) {
        super.init(size: size)
        _level = level
        _timerCount = timerCount
        _duration = duration
        _oldScore = oldScore
        _newScore = newScore
        _achievements = achievements
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        // Copy Level ID
        _copyLabel = addLabel("Copy Level ID", color: SKColor.grayColor())
        
        // Quit
        _quitLabel = addLabel("Quit", color: SKColor.whiteColor())
        
        // Continue
        _continueLabel = addLabel("Continue", color: SKColor.whiteColor())
        
        // Duration
        let durationStr = String(format:"%d:%02d", abs(_duration) / 60, abs(_duration) % 60)
        _durationLabel = addLabel(durationStr, color: SKColor.whiteColor())
        
        // Stars
        _starDisplay = StarDisplay(scene: self, oldScore: _oldScore, newScore: Storage.loadScore(_level._level))
        addChild(_starDisplay)
        
        // Star Label
        let oldNumStars = Storage.loadStars() - _newScore + _oldScore
        _starLabel = StarLabel(text: "\(oldNumStars)", color: SKColor.whiteColor(), anchor: .Left)
        addChild(_starLabel)
        
        // Social
        _muteShareDisplay = MuteShareDisplay(shareType: .Score, level: _level, duration: _duration)
        addChild(_muteShareDisplay)
        
        _achievementPopups = AchievementManager.displayAchievements(_achievements, scene: self)
        
        refreshLayout()
    }
    
    func addLabel(text: String, color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: Constants.FONT)
        label.text = text
        label.fontColor = color
        self.addChild(label)
        return label
    }
    
    func fireStars() {
        let p = convertPoint(_starLabel._star.position, fromNode: _starLabel)
        _starDisplay.explodeTo(p, completion: { (numStars: Int) -> Void in
            for i in 0 ..< numStars {
                let delay = Int64(0.05 * Double(NSEC_PER_SEC) * Double(i))
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delay), dispatch_get_main_queue(), {
                    let num = Int(self._starLabel.getText())
                    self._starLabel.setText(String(num! + 1))
                })
            }
        })
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if !_achievementPopups.isEmpty {
            _achievementPopups.removeFirst().close()
            if _achievementPopups.isEmpty {
                fireStars()
            }
            return
        }
    
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
            AppDelegate.popViewController(animated: true)
        } else if isPointInBounds(p, node: _continueLabel) {
            // Continue
            continuePressed()
        } else {
            _muteShareDisplay.tap(p)
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
    
    func continuePressed() {
        if _level is CustomLevel {
            AppDelegate.popViewController(animated: true)
        } else {
            // Don't advance level past the stored max (in case we completed a CustomLevel)
            var nextLevelNum = _level._level
            if nextLevelNum < Storage.loadMaxLevel() {
                nextLevelNum += 1
            }
            let nextLevel = Level(level: nextLevelNum, seed: nil)
            let nextScene = LevelGenerationScene(size: size, level: nextLevel)
            AppDelegate.pushViewController(SKViewController(scene: nextScene), animated: true, offset: 0)
        }
    }
    
    func refreshLayout() {
        if _level == nil {
            return
        }
    
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        if _titleLabel != nil {
            _titleLabel.removeFromParent()
        }
        var titleText = "Level Complete!"
        if _level is CustomLevel {
            titleText = "Custom\n" + titleText
        }
        _titleLabel = SKMultilineLabel(text: titleText, labelWidth: w * 0.9, pos: CGPoint(x: w * 0.5, y: h * 0.85), fontName: Constants.FONT, fontSize: s * Constants.TITLE_SCALE, fontColor: Constants.TITLE_COLOR, spacing: 1.5, alignment: .Center, shouldShowBorder: false)
        addChild(_titleLabel)
        
        _copyLabel.fontSize = s * 0.04
        _copyLabel.position = CGPoint(x: w * 0.5, y: h * 0.67 - s * 0.05)
        
        _quitLabel.fontSize = s * Constants.TEXT_SCALE
        _quitLabel.position = CGPoint(x: w * 0.15, y: h * 0.47)
        
        _continueLabel.fontSize = s * Constants.TEXT_SCALE
        _continueLabel.position = CGPoint(x: w * 0.85, y: h * 0.47)
        
        _durationLabel.fontSize = s * Constants.TEXT_SCALE
        _durationLabel.position = CGPoint(x: w * 0.5, y: h * 0.47)
        
        _starDisplay.position = CGPoint(x: w * 0.5, y: h * 0.3)
        _starDisplay.setSize(s * 0.2)
        
        _muteShareDisplay.position = CGPointZero
        _muteShareDisplay.refreshLayout(size)
        
        _starLabel.setSize(s * Constants.TEXT_SCALE)
        _starLabel.position = CGPoint(x: s * Constants.ICON_SCALE * 1.2, y: h - s * Constants.ICON_SCALE)
        
        if _levelLabel != nil {
            _levelLabel.removeFromParent()
        }
        _levelLabel = LevelLabel(level: _level._level, seed:_level.getSeedString(), size: s * 0.08, color: SKColor.whiteColor())
        _levelLabel.position = CGPoint(x: w * 0.5, y: h * 0.67)
        self.addChild(_levelLabel)
        
        for popup in _achievementPopups {
            popup.refreshLayout(size)
        }
        
        if _achievementPopups.isEmpty {
            fireStars()
        }
    }
    
    override func didChangeSize(oldSize: CGSize) {
        refreshLayout()
    }
}
