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

    var _level: Level! = nil
    var _gameView: GameView! = nil
    
    var _tapRecognizer: UITapGestureRecognizer! = nil
    var _swipeUpRecognizer: UISwipeGestureRecognizer! = nil
    var _swipeDownRecognizer: UISwipeGestureRecognizer! = nil
    var _swipeLeftRecognizer: UISwipeGestureRecognizer! = nil
    var _swipeRightRecognizer: UISwipeGestureRecognizer! = nil
    var _pinchRecognizer: UIPinchGestureRecognizer! = nil
    var _panRecognizer: UIPanGestureRecognizer! = nil
    
    var _lastScale: CGFloat = 1
    var _bringingBack = false

    init(size: CGSize, level: Level) {
        super.init(size: size)
        _level = level
        
        let x = size.width / 2
        let y = size.height / 2
        // Scale 1.0 means the level fits in the screen
        let scale = min(size.width / CGFloat(level._width), size.height / CGFloat(level._height))
        _gameView = GameView(level: level, x: x, y: y, scale: scale)
        
        addChild(_gameView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor(red: 0.15, green: 0, blue: 0.15, alpha: 1)
    
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
    }
    
    override func willMoveFromView(view: SKView) {
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
    
    func handleTap(recognizer: UITapGestureRecognizer?) {
        let pauseScene = PauseScene(size: size, level: _level._level, seed: _level._seed, playScene: self)
        pauseScene.scaleMode = scaleMode
        view?.presentScene(pauseScene)
    }
    
    func handleSwipeUp(sender: UITapGestureRecognizer?) {
        print("swipe up")
    }
    
    func handleSwipeDown(sender: UITapGestureRecognizer?) {
        print("swipe down")
    }
    
    func handleSwipeLeft(sender: UITapGestureRecognizer?) {
        print("swipe left")
    }
    
    func handleSwipeRight(sender: UITapGestureRecognizer?) {
        print("swipe right")
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
        if _bringingBack {
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
        
        if x + w < width && x < 0 {
            dX = min(width - x - w, -x)
        } else if x + w > width && x > 0 {
            dX = max(width - x - w, -x)
        }
        if y + h < height && y < 0 {
            dY = min(height - y - h, -y)
        } else if y + h > height && y > 0 {
            dY = max(height - y - h, -y)
        }
        
        if dX != 0 || dY != 0 {
            _gameView.runAction(SKAction.moveByX(dX, y: dY, duration: 0.25), completion: { () -> Void in self._bringingBack = false })
        }
    }
}
