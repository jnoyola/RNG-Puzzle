//
//  PlayScene.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 9/24/15.
//  Copyright © 2015 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit

class PlayScene: SKScene, UIGestureRecognizerDelegate {


    var _level: LevelProtocol! = nil
    var _gameView: GameView! = nil
    var _coinLabel: CoinLabel! = nil
    var _timerLabel: SKLabelNode! = nil
    var _timer: NSTimer? = nil
    var _timerFlash: NSTimer? = nil
    var _timerTotal = 0
    var _timerCount = 0
    
    var _tapRecognizer: UITapGestureRecognizer! = nil
    var _swipeUpRecognizer: UISwipeGestureRecognizer! = nil
    var _swipeDownRecognizer: UISwipeGestureRecognizer! = nil
    var _swipeLeftRecognizer: UISwipeGestureRecognizer! = nil
    var _swipeRightRecognizer: UISwipeGestureRecognizer! = nil
    var _pinchRecognizer: UIPinchGestureRecognizer! = nil
    var _panRecognizer: UIPanGestureRecognizer! = nil
    
    var _lastScale: CGFloat = 1
    var _bringingBack = false
    
    var _oldSize: CGSize! = nil
    var _oldMarginRight: CGFloat = 0
    var _oldMarginBottom: CGFloat = 0
    var _marginRight: CGFloat = 0
    var _marginBottom: CGFloat = 0
    let _margin: CGFloat = 50

    init(size: CGSize, level: LevelProtocol) {
        super.init(size: size)
        _level = level
        _timerTotal = 30 + _level._level / 2
        _timerCount = _timerTotal

        createGameView()
        
        refreshCoins()
        refreshTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createGameView() {
        _gameView = GameView(level: _level, parent: self, winCallback: complete)
        addChild(_gameView)
    }

    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor(red: 0.4, green: 0, blue: 0.4, alpha: 1)
    
        // Tap for pausing
        _tapRecognizer = UITapGestureRecognizer(target: self, action: "handleTap:")
        
        // Swipe for moving
        _swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeUp:")
        _swipeUpRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        _swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeDown:")
        _swipeDownRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        _swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeLeft:")
        _swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        _swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeRight:")
        _swipeRightRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        
        // Pinch for zooming
        _pinchRecognizer = UIPinchGestureRecognizer(target: self, action: "handlePinch:")
        _pinchRecognizer.delegate = self
        
        // Pan for panning
        _panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        _panRecognizer.minimumNumberOfTouches = 2
        _panRecognizer.delegate = self
        
        _tapRecognizer.requireGestureRecognizerToFail(_swipeUpRecognizer)
        _tapRecognizer.requireGestureRecognizerToFail(_swipeDownRecognizer)
        _tapRecognizer.requireGestureRecognizerToFail(_swipeLeftRecognizer)
        _tapRecognizer.requireGestureRecognizerToFail(_swipeRightRecognizer)
        
        view.addGestureRecognizer(_tapRecognizer)
        view.addGestureRecognizer(_swipeUpRecognizer)
        view.addGestureRecognizer(_swipeDownRecognizer)
        view.addGestureRecognizer(_swipeLeftRecognizer)
        view.addGestureRecognizer(_swipeRightRecognizer)
        view.addGestureRecognizer(_pinchRecognizer)
        view.addGestureRecognizer(_panRecognizer)
        
        startTimer()
    }
    
    override func willMoveFromView(view: SKView) {
        _timer?.invalidate()
        _timerFlash?.invalidate()
        _timerFlash = nil
    
        view.removeGestureRecognizer(_tapRecognizer)
        view.removeGestureRecognizer(_swipeUpRecognizer)
        view.removeGestureRecognizer(_swipeDownRecognizer)
        view.removeGestureRecognizer(_swipeLeftRecognizer)
        view.removeGestureRecognizer(_swipeRightRecognizer)
        view.removeGestureRecognizer(_pinchRecognizer)
        view.removeGestureRecognizer(_panRecognizer)
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        let pauseScene = PauseScene(size: size, level: _level, playScene: self, timerCount: _timerCount)
        pauseScene.scaleMode = scaleMode
        view?.presentScene(pauseScene)
    }
    
    func handleSwipeUp(sender: UITapGestureRecognizer) {
        _gameView.attemptMove(.Up, swipe: sender.locationInView(sender.view))
    }
    
    func handleSwipeDown(sender: UITapGestureRecognizer) {
        _gameView.attemptMove(.Down, swipe: sender.locationInView(sender.view))
    }
    
    func handleSwipeLeft(sender: UITapGestureRecognizer) {
        _gameView.attemptMove(.Left, swipe: sender.locationInView(sender.view))
    }
    
    func handleSwipeRight(sender: UITapGestureRecognizer) {
        _gameView.attemptMove(.Right, swipe: sender.locationInView(sender.view))
    }
    
    func handlePinch(sender: UIPinchGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended {
            _lastScale = 1.0
            bringBackToScreen()
            return
        }
        _bringingBack = false
        
        // Scale the GameView
        let oldScale = _gameView._scale
        _gameView.scale(sender.scale / _lastScale)
        _lastScale = sender.scale
        
        // Keep the pinch location fixed
        let newScale = _gameView._scale
        let p = sender.locationInView(sender.view)
        let x0 = p.x
        let y0 = size.height - p.y
        let x1 = _gameView.position.x
        let y1 = _gameView.position.y
        _gameView.position = CGPoint(x: x0 - (x0-x1) * (newScale/oldScale), y: y0 - (y0-y1) * (newScale/oldScale))
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Ended {
            bringBackToScreen()
            return
        }
        _bringingBack = false
        
        let v = sender.translationInView(sender.view)
        let p = _gameView.position
        _gameView.position = CGPoint(x: p.x + v.x, y: p.y - v.y)
        sender.setTranslation(CGPointZero, inView: sender.view)
    }
    
    func bringBackToScreen() {
        if _bringingBack || view == nil {
            return
        }
        _bringingBack = true
        
        var dX: CGFloat = 0.0
        var dY: CGFloat = 0.0
        let x = _gameView.position.x
        let y = _gameView.position.y
        let w = _gameView.getWidth()
        let h = _gameView.getHeight()
        let width = view!.bounds.width
        let height = view!.bounds.height
        
        if x + w < width - _marginRight - _margin && x < _margin {
            dX = min(width - _marginRight - _margin - x - w, _margin - x)
        } else if x + w > width - _marginRight - _margin && x > _margin {
            dX = max(width - _marginRight - _margin - x - w, _margin - x)
        }
        if y + h < height - _margin && y < _marginBottom + _margin {
            dY = min(height - _margin - y - h, _marginBottom + _margin - y)
        } else if y + h > height - _margin && y > _marginBottom + _margin {
            dY = max(height - _margin - y - h, _marginBottom + _margin - y)
        }
        
        if dX != 0 || dY != 0 {
            _gameView.runAction(SKAction.moveByX(dX, y: dY, duration: 0.25), completion: { () -> Void in
                self._bringingBack = false
            })
        }
    }
    
    func startTimer() {
        _timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "tick", userInfo: nil, repeats: true)
    }
    
    func tick() {
        --_timerCount
        updateTimerLabel()
    }
    
    func flashTimer() {
        _timerLabel.hidden = !_timerLabel.hidden
    }
    
    func updateTimerLabel() {
        var str = String(format:"%d:%02d", abs(_timerCount) / 60, abs(_timerCount) % 60)
        if _timerCount < 0 {
            str = "-" + str
        }
        _timerLabel.text = str
        if _timerCount <= 10 && _timerFlash == nil {
            _timerFlash = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "flashTimer", userInfo: nil, repeats: true)
        }
        if _timerCount <= 0 {
            _timerLabel.fontColor = UIColor.redColor()
        }
    }
    
    func complete() {
        // Make sure we're playing a Level, not a CustomLevel
        if _timerCount > 0 && _level is Level && _level._level == Storage.loadLevel() {
            Storage.incLevel()
        }
    
        let levelCompleteScene = LevelCompleteScene(size: size, level: _level, timerCount: _timerCount, duration: _timerTotal - _timerCount)
        levelCompleteScene.scaleMode = scaleMode
        (UIApplication.sharedApplication().delegate! as! AppDelegate).pushViewController(SKViewController(scene: levelCompleteScene), animated: true)
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
        _coinLabel.zPosition = 50
        addChild(_coinLabel)
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
    
    func changedSize() {
        refreshCoins()
        refreshTimer()
    }
    
    override func didChangeSize(oldSize: CGSize) {
        if _gameView != nil && oldSize != _oldSize {
            _oldMarginRight = _marginRight
            _oldMarginBottom = _marginBottom
            changedSize()
            
            let x = _gameView!.position.x + (size.width - _marginRight - oldSize.width + _oldMarginRight) / 2
            let y = _gameView!.position.y + (size.height - _marginBottom - oldSize.height + _oldMarginBottom) / 2 + _marginBottom - _oldMarginBottom
            _gameView!.position = CGPoint(x: x, y: y)
            _gameView!.changeSize()
            
            bringBackToScreen()
        }
        _oldSize = size
    }
}
