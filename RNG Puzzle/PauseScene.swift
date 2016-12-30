//
//  PauseScene.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 9/24/15.
//  Copyright © 2015 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit
import StoreKit

class PauseScene: SKScene {
    
    var _level: LevelProtocol! = nil
    var _playScene: PlayScene! = nil
    var _timerCount = 0
    
    var _titleLabel: SKLabelNode! = nil
    var _copyLabel: SKLabelNode! = nil
    var _quitLabel: SKLabelNode! = nil
    var _resumeLabel: SKLabelNode! = nil
    var _levelLabel: LevelLabel! = nil
    var _hintLabel: StarLabel! = nil
    var _starLabel: StarLabel! = nil
    var _timerLabel: SKLabelNode! = nil
    var _muteShareDisplay: MuteShareDisplay! = nil
    
    var _purchasePopup: PurchasePopup? = nil

    init(size: CGSize, level: LevelProtocol, playScene: PlayScene, timerCount: Int) {
        super.init(size: size)
        _level = level
        _playScene = playScene
        _timerCount = timerCount
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        // Title
        _titleLabel = addLabel("Paused", color: Constants.TITLE_COLOR)
        
        // Copy Level ID
        _copyLabel = addLabel("Copy Level ID", color: SKColor.gray)
        
        // Quit
        _quitLabel = addLabel("Quit", color: SKColor.white)
        
        // Resume
        _resumeLabel = addLabel("Resume", color: SKColor.white)
        
        // Star Label
        _starLabel = StarLabel(text: "\(Storage.loadStars())", color: SKColor.white, anchor: .left)
        addChild(_starLabel)
        
        // Timer
        _timerLabel = SKLabelNode(fontNamed: Constants.FONT)
        _timerLabel.horizontalAlignmentMode = .left
        _timerLabel.fontColor = UIColor.white
        updateTimerLabel()
        addChild(_timerLabel)
        
        // Social
        _muteShareDisplay = MuteShareDisplay(shareType: .Level, level: _level)
        addChild(_muteShareDisplay)
        
        refreshLayout()
        
        _playScene.view?.isPaused = true
    }
    
    override func willMove(from view: SKView) {
        _playScene.view?.isPaused = false
    }
    
    func addLabel(_ text: String, color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: Constants.FONT)
        label.text = text
        label.fontColor = color
        self.addChild(label)
        return label
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let p = touch.location(in: self)
        
        if _purchasePopup != nil {
            _purchasePopup!.touch(p)
            return
        }
        
        let w = size.width
        let h = size.height
        
        if p.x > w * 0.25 && p.x < w * 0.75 && p.y > h * 0.55 && p.y < h * 0.79 {
            // Copy Level ID
            UIPasteboard.general.string = _level.getCode()
            _copyLabel.text = "Level ID Copied"
        } else if isPointInBounds(p, node: _quitLabel) {
            // Quit
            AppDelegate.popViewController(animated: true)
        } else if isPointInBounds(p, node: _resumeLabel) {
            // Resume
            view?.presentScene(_playScene)
        } else {
            _muteShareDisplay.tap(p)
        }
    }
    
    func isPointInBounds(_ p: CGPoint, node: SKNode) -> Bool {
        let x1 = node.frame.minX - node.frame.height * 0.5
        let x2 = node.frame.maxX + node.frame.height * 0.5
        let y1 = node.frame.minY - node.frame.height * 0.5
        let y2 = node.frame.maxY + node.frame.height * 0.5
        if p.x > x1 && p.x < x2 && p.y > y1 && p.y < y2 {
            return true
        }
        return false
    }
    
    func refreshLayout() {
        if _level == nil {
            return
        }
    
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        _titleLabel.fontSize = s * Constants.TITLE_SCALE
        _titleLabel.position = CGPoint(x: w * 0.5, y: h * 0.85)
        
        _copyLabel.fontSize = s * 0.04
        _copyLabel.position = CGPoint(x: w * 0.5, y: h * 0.67 - s * 0.05)
        
        _quitLabel.fontSize = s * Constants.TEXT_SCALE
        _quitLabel.position = CGPoint(x: w * 0.15, y: h * 0.47)
        
        _resumeLabel.fontSize = s * Constants.TEXT_SCALE
        _resumeLabel.position = CGPoint(x: w * 0.85, y: h * 0.47)
        
        _muteShareDisplay.position = CGPoint.zero
        _muteShareDisplay.refreshLayout(size: size)
        
        if _levelLabel != nil {
            _levelLabel.removeFromParent()
        }
        _levelLabel = LevelLabel(level: _level._level, seed:_level.getSeedString(), size: s * Constants.TEXT_SCALE, color: SKColor.white)
        _levelLabel.position = CGPoint(x: w * 0.5, y: h * 0.67)
        self.addChild(_levelLabel)
        
        refreshHUD()
        
        refreshPurchasePopup()
    }
    
    func refreshHUD() {
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        _starLabel.setSize(s * Constants.TEXT_SCALE)
        _starLabel.position = CGPoint(x: s * Constants.ICON_SCALE * 1.2, y: h - s * Constants.ICON_SCALE)
        
        _timerLabel.fontSize = s * Constants.TEXT_SCALE
        _timerLabel.position = CGPoint(x: w - s * Constants.TEXT_SCALE * 2, y: h - s * Constants.ICON_SCALE)
    }
    
    func updateStarLabel() {
        let text = "\(Storage.loadStars())"
        _starLabel.setText(text)
        _playScene.updateStarLabel()
    }
    
    func updateTimerLabel() {
        let str = String(format:"%d:%02d", abs(_timerCount) / 60, abs(_timerCount) % 60)
        _timerLabel.text = str
        if _timerCount <= 10 {
            _timerLabel.fontColor = UIColor.red
        }
    }
    
    func refreshPurchasePopup() {
        let w = size.width
        let h = size.height
        
        _purchasePopup?.refreshLayout(size: CGSize(width: w, height: h))
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        refreshLayout()
    }
}
