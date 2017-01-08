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
    var _retryLabel: SKLabelNode! = nil
    var _nextLabel: SKLabelNode! = nil
    var _levelLabel: LevelLabel! = nil
    var _durationLabel: SKLabelNode! = nil
    var _starLabel: StarLabel! = nil
    var _starDisplay: StarDisplay! = nil
    var _muteShareDisplay: MuteShareDisplay! = nil
    
    var _achievementPopups: [AchievementPopup]! = nil
    
    var _hasAnimated = false

    init(size: CGSize, level: LevelProtocol, timerCount: Int, duration: Int, achievements: [GKAchievement], oldScore: Int, newScore: Int) {
        super.init(size: size)
        _level = level
        _timerCount = timerCount
        _duration = duration
        _newScore = newScore
        _achievements = achievements
        
        if level is CustomLevel {
            _oldScore = newScore
        } else {
            _oldScore = oldScore
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        // Copy Level ID
        _copyLabel = addLabel("Copy Level ID", color: SKColor.gray)
        
        // Quit
        _quitLabel = addLabel("Quit", color: SKColor.white)
        
        // Retry
        _retryLabel = addLabel("Retry", color: SKColor.white)
        
        // Next
        _nextLabel = addLabel("Next", color: SKColor.white)
        
        // Duration
        _durationLabel = addLabel("0:00", color: SKColor.white)
        
        // Stars
        _starDisplay = StarDisplay(scene: self, oldScore: _oldScore, newScore: _newScore)
        addChild(_starDisplay)
        
        // Star Label
        var oldNumStars = Storage.loadStars()
        if _newScore > _oldScore {
            oldNumStars += -_newScore + _oldScore
        }
        _starLabel = StarLabel(text: "\(oldNumStars)", color: SKColor.white, anchor: .left)
        addChild(_starLabel)
        
        // Social
        _muteShareDisplay = MuteShareDisplay(shareType: .Score, level: _level, duration: _duration)
        addChild(_muteShareDisplay)
        
        _achievementPopups = AchievementManager.displayAchievements(_achievements, scene: self)
        
        refreshLayout()
    }
    
    func addLabel(_ text: String, color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: Constants.FONT)
        label.text = text
        label.fontColor = color
        self.addChild(label)
        return label
    }
    
    func animate() {
        if !_hasAnimated {
            _hasAnimated = true
            countTimer()
        }
    }
    
    func countTimer(animationTime: Double = 0) {
        let animationDuration = 0.5
        var animationStep = animationDuration / Double(_duration)
        if animationStep < 0.01 {
            animationStep = 0.01
        }
    
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + animationStep) {
            let nextAnimationTime = animationTime + animationStep
            var counter = Int(Double(self._duration) * nextAnimationTime / animationDuration)
            if counter >= self._duration {
                counter = self._duration
                self.fireStars()
            } else {
                self.countTimer(animationTime: nextAnimationTime)
            }
            let str = String(format:"%d:%02d", abs(counter) / 60, abs(counter) % 60)
            DispatchQueue.main.async {
                self._durationLabel.text = str
            }
        }
    }
    
    func fireStars() {
        let p = convert(_starLabel._star.position, from: _starLabel)
        _starDisplay.explodeTo(p, completion: { (numStars: Int) -> Void in
            for i in 0 ..< numStars {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15 * Double(i)) {
                    let num = Int(self._starLabel.getText())
                    self._starLabel.setText(String(num! + 1))
                }
            }
        })
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !_achievementPopups.isEmpty {
            _achievementPopups.removeFirst().close()
            if _achievementPopups.isEmpty {
                animate()
            }
            return
        }
    
        let touch = touches.first!
        let p = touch.location(in: self)
        
        let w = size.width
        let h = size.height
        
        if p.x > w * 0.25 && p.x < w * 0.75 && p.y > h * 0.55 && p.y < h * 0.79 {
            // Copy Level ID
            UIPasteboard.general.string = _level.getCode()
            _copyLabel.text = "Level ID Copied"
        } else if isPointInBounds(p, node: _quitLabel) {
            // Quit
            AppDelegate.popViewController(animated: true)
        } else if isPointInBounds(p, node: _retryLabel) {
            // Retry
            retryPressed()
        } else if isPointInBounds(p, node: _nextLabel) {
            // Next
            nextPressed()
        } else {
            _muteShareDisplay.tap(p)
        }
    }
    
    func isPointInBounds(_ p: CGPoint, node: SKNode) -> Bool {
        let x1 = node.frame.minX - 30
        let x2 = node.frame.maxX + 30
        let y1 = node.frame.minY - 30
        let y2 = node.frame.maxY + 30
        if p.x > x1 && p.x < x2 && p.y > y1 && p.y < y2 {
            return true
        }
        return false
    }
    
    func retryPressed() {
        if _level is CustomLevel {
            let nextScene = PlayScene(size: size, level: _level)
            AppDelegate.pushViewController(SKViewController(scene: nextScene), animated: true, offset: 0)
        } else {
            let nextLevel = Level(level: _level._level, seed: nil)
            let nextScene = LevelGenerationScene(size: size, level: nextLevel)
            AppDelegate.pushViewController(SKViewController(scene: nextScene), animated: true, offset: 0)
        }
    }
    
    func nextPressed() {
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
        _titleLabel = SKMultilineLabel(text: titleText, labelWidth: w * 0.9, pos: CGPoint(x: w * 0.5, y: h * 0.85), fontName: Constants.FONT, fontSize: s * Constants.TITLE_SCALE, fontColor: Constants.TITLE_COLOR, spacing: 1.1, alignment: .center, shouldShowBorder: false)
        addChild(_titleLabel)
        
        _copyLabel.fontSize = s * 0.04
        _copyLabel.position = CGPoint(x: w * 0.5, y: h * 0.67 - s * 0.05)
        
        _quitLabel.fontSize = s * Constants.TEXT_SCALE
        _quitLabel.position = CGPoint(x: w * 0.15, y: h * 0.47)
        
        _retryLabel.fontSize = s * Constants.TEXT_SCALE
        _retryLabel.position = CGPoint(x: w * 0.5, y: h * 0.47)
        
        _nextLabel.fontSize = s * Constants.TEXT_SCALE
        _nextLabel.position = CGPoint(x: w * 0.85, y: h * 0.47)
        
        _durationLabel.fontSize = s * Constants.TEXT_SCALE
        _durationLabel.position = CGPoint(x: w * 0.5, y: h * 0.36 - s * 0.06)
        
        _starDisplay.position = CGPoint(x: w * 0.5, y: h * 0.36 - s * 0.21)
        _starDisplay.setSize(s * 0.2)
        
        _muteShareDisplay.position = CGPoint.zero
        _muteShareDisplay.refreshLayout(size: size)
        
        _starLabel.setSize(s * Constants.TEXT_SCALE)
        _starLabel.position = CGPoint(x: s * Constants.ICON_SCALE * 1.2, y: h - s * Constants.ICON_SCALE)
        
        if _levelLabel != nil {
            _levelLabel.removeFromParent()
        }
        _levelLabel = LevelLabel(level: _level._level, seed:_level.getSeedString(), size: s * 0.08, color: SKColor.white)
        _levelLabel.position = CGPoint(x: w * 0.5, y: h * 0.67)
        self.addChild(_levelLabel)
        
        for popup in _achievementPopups {
            popup.refreshLayout(size: size)
        }
        
        if _achievementPopups.isEmpty {
            animate()
        }
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        refreshLayout()
    }
}
