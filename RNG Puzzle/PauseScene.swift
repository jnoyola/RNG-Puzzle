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
    var _hintLabel: CoinLabel! = nil
    var _coinLabel: CoinLabel! = nil
    var _timerLabel: SKLabelNode! = nil
    var _messagesButton: SKSpriteNode! = nil
    var _facebookButton: SKSpriteNode! = nil
    var _twitterButton: SKSpriteNode! = nil
    
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
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        // Title
        _titleLabel = addLabel("Paused", color: SKColor.blueColor())
        
        // Copy Level ID
        _copyLabel = addLabel("Copy Level ID", color: SKColor.grayColor())
        
        // Quit
        _quitLabel = addLabel("Quit", color: SKColor.whiteColor())
        
        // Resume
        _resumeLabel = addLabel("Resume", color: SKColor.whiteColor())
        
        // Social
        _messagesButton = SKSpriteNode(imageNamed: "icon_messages")
        _facebookButton = SKSpriteNode(imageNamed: "icon_facebook")
        _twitterButton = SKSpriteNode(imageNamed: "icon_twitter")
        addChild(_messagesButton)
        addChild(_facebookButton)
        addChild(_twitterButton)
        
        refreshLayout()
        
        _playScene.view?.paused = true
    }
    
    override func willMoveFromView(view: SKView) {
        _playScene.view?.paused = false
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
        
        if _purchasePopup != nil {
            _purchasePopup!.touch(p)
            return
        }
        
        let w = size.width
        let h = size.height
        
        if p.x > w * 0.25 && p.x < w * 0.75 && p.y > h * 0.55 && p.y < h * 0.79 {
            // Copy Level ID
            UIPasteboard.generalPasteboard().string = _level.getCode()
            _copyLabel.text = "Level ID Copied"
        } else if p.x > _hintLabel.position.x + _hintLabel._minX
               && p.x < _hintLabel.position.x + _hintLabel._maxX
               && p.y > _hintLabel.position.y + _hintLabel._minY
               && p.y < _hintLabel.position.y + _hintLabel._maxY {
            // Hint
            attemptHint()
        } else if isPointInBounds(p, node: _quitLabel) {
            // Quit
            (UIApplication.sharedApplication().delegate!.window!!.rootViewController! as! UINavigationController).popToRootViewControllerAnimated(true)
        } else if isPointInBounds(p, node: _resumeLabel) {
            // Resume
            view?.presentScene(_playScene)
        } else if isPointInBounds(p, node: _facebookButton) {
            // TODO add level code to notification
            AlertManager.defaultManager().shareFacebook()
        } else if isPointInBounds(p, node: _messagesButton) {
            // TODO add level code to notification
            AlertManager.defaultManager().shareMessages()
        } else if isPointInBounds(p, node: _twitterButton) {
            // TODO add level code to notification
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
    
    func attemptHint() {
        if Storage.loadCoins() > 0 {
            if _playScene._gameView.hint() {
                Storage.addCoins(-1)
                refreshCoins()
                _hintLabel.animate()
                _coinLabel.animate()
            }
        } else {
            _purchasePopup = PurchasePopup(parent: self)
            refreshPurchasePopup()
            _purchasePopup!.zPosition = 1000
            _purchasePopup!.position = CGPoint(x: 0, y: -_purchasePopup!.frame.height)
            addChild(_purchasePopup!)
            _purchasePopup!.runAction(SKAction.moveToY(0, duration: 0.2), completion: {
                self._purchasePopup?.activate()
            })
        }
    }
    
    func closePurchasePopup() {
        _purchasePopup!.runAction(SKAction.moveToY(-_purchasePopup!.frame.height, duration: 0.2), completion: {
            self._purchasePopup!.removeFromParent()
            self._purchasePopup = nil
        })
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
        
        _resumeLabel.fontSize = s * 0.064
        _resumeLabel.position = CGPoint(x: w * 0.85, y: h * 0.47)
        
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
        
        if _hintLabel != nil {
            _hintLabel.removeFromParent()
        }
        _hintLabel = CoinLabel(text: "Hint", size: s * 0.064, color: SKColor.whiteColor())
        _hintLabel.position = CGPoint(x: w * 0.5, y: h * 0.47)
        addChild(_hintLabel)
        
        refreshCoins()
        refreshTimer()
        
        refreshPurchasePopup()
    }
    
    func refreshCoins() {
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        if _coinLabel != nil {
            _coinLabel.removeFromParent()
        }
        _coinLabel = CoinLabel(text: "\(Storage.loadCoins())", size: s * 0.064, color: SKColor.whiteColor(), coinScale: 1.3, anchor: .Left)
        _coinLabel.position = CGPoint(x: s * 0.1, y: h - s * 0.1)
        addChild(_coinLabel)
        
        _playScene.refreshCoins()
    }
    
    func refreshTimer() {
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        if _timerLabel != nil {
            _timerLabel.removeFromParent()
        }
        _timerLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        _timerLabel.horizontalAlignmentMode = .Left
        _timerLabel.fontColor = UIColor.whiteColor()
        _timerLabel.fontSize = s * 0.064
        _timerLabel.position = CGPoint(x: w - s * 0.18, y: h - s * 0.1)
        updateTimerLabel()
        addChild(_timerLabel)
    }
    
    func updateTimerLabel() {
        var str = String(format:"%d:%02d", abs(_timerCount) / 60, abs(_timerCount) % 60)
        if _timerCount < 0 {
            str = "-" + str
        }
        _timerLabel.text = str
        if _timerCount <= 0 {
            _timerLabel.fontColor = UIColor.redColor()
        }
    }
    
    func refreshPurchasePopup() {
        let w = size.width
        let h = size.height
        
        _purchasePopup?.refreshLayout(CGSize(width: w, height: h))
    }
    
    override func didChangeSize(oldSize: CGSize) {
        refreshLayout()
    }
}
