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
    var _starLabel: StarLabel! = nil
    var _timerLabel: SKLabelNode! = nil
    var _pauseButton: SKSpriteNode! = nil
    var _hintLabel: StarLabel! = nil
    
    var _timerTotal = 0
    var _timerCount = 0.0
    var _prevTick = 0
    var _prevUpdateTime: CFTimeInterval? = nil
    var _timerActive = false
    var _numTimerExpirations = 0
    
    var _starEmitter: SKEmitterNode! = nil
    
    var _foregroundNotification: NSObjectProtocol! = nil
    
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
        _timerCount = Double(_timerTotal)
        _prevTick = _timerTotal

        createHUD()
        refreshHUD()
        
        createGameView()
        createStars()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(_foregroundNotification)
    }
    
    func createGameView() {
        _gameView = GameView(level: _level, parent: self, winCallback: complete)
        addChild(_gameView)
        
        if !_gameView.canHint() {
            _hintLabel.disable()
        }
    }
    
    func createStars() {
        let path = Bundle.main.path(forResource: "StarBackground", ofType: "sks")
        _starEmitter = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as! SKEmitterNode
        _starEmitter.particlePositionRange = CGVector(dx: frame.width, dy: frame.height)
        _starEmitter.targetNode = self
        _starEmitter.zPosition = -10
        
        refreshStars()
        self.addChild(_starEmitter)
        
        _foregroundNotification = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: nil, using: { Void in self.doPause() })
    }
    
    func createHUD() {
        // Star Label
        _starLabel = StarLabel(text: "\(Storage.loadStars())", color: SKColor.white, anchor: .left)
        _starLabel.zPosition = 50
        addChild(_starLabel)
        
        // Timer
        _timerLabel = SKLabelNode(fontNamed: Constants.FONT)
        _timerLabel.horizontalAlignmentMode = .left
        _timerLabel.fontColor = UIColor.white
        _timerLabel.zPosition = 50
        updateTimerLabel()
        addChild(_timerLabel)
        
        // Pause
        _pauseButton = SKSpriteNode(imageNamed: "icon_pause")
        _pauseButton.zPosition = 50
        addChild(_pauseButton)
        
        // Hint Label
        _hintLabel = StarLabel(text: "Hint", color: SKColor.white, starText: String(Constants.HINT_COST), anchor: .left)
        addChild(_hintLabel)
    }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        _starEmitter.resetSimulation()
        
        // Tap for pausing
        _tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        // Swipe for moving
        _swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp))
        _swipeUpRecognizer.direction = UISwipeGestureRecognizerDirection.up
        _swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        _swipeDownRecognizer.direction = UISwipeGestureRecognizerDirection.down
        _swipeLeftRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft))
        _swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirection.left
        _swipeRightRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight))
        _swipeRightRecognizer.direction = UISwipeGestureRecognizerDirection.right
        
        // Pinch for zooming
        _pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        _pinchRecognizer.delegate = self
        
        // Pan for panning
        _panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        _panRecognizer.minimumNumberOfTouches = 2
        _panRecognizer.delegate = self
        
        _tapRecognizer.require(toFail: _swipeUpRecognizer)
        _tapRecognizer.require(toFail: _swipeDownRecognizer)
        _tapRecognizer.require(toFail: _swipeLeftRecognizer)
        _tapRecognizer.require(toFail: _swipeRightRecognizer)
        
        view.addGestureRecognizer(_tapRecognizer)
        view.addGestureRecognizer(_swipeUpRecognizer)
        view.addGestureRecognizer(_swipeDownRecognizer)
        view.addGestureRecognizer(_swipeLeftRecognizer)
        view.addGestureRecognizer(_swipeRightRecognizer)
        view.addGestureRecognizer(_pinchRecognizer)
        view.addGestureRecognizer(_panRecognizer)
    }
    
    override func willMove(from view: SKView) {
        _prevUpdateTime = nil
        
        view.removeGestureRecognizer(_tapRecognizer)
        view.removeGestureRecognizer(_swipeUpRecognizer)
        view.removeGestureRecognizer(_swipeDownRecognizer)
        view.removeGestureRecognizer(_swipeLeftRecognizer)
        view.removeGestureRecognizer(_swipeRightRecognizer)
        view.removeGestureRecognizer(_pinchRecognizer)
        view.removeGestureRecognizer(_panRecognizer)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        let p = sender.location(in: sender.view)
        let yMin = h - s * Constants.TEXT_SCALE * 2.6
        let xMinPause = w - s * Constants.TEXT_SCALE * 2.6
        let xMaxHint = _hintLabel.position.x + _hintLabel._maxX
        
        if p.y > yMin {
            if p.x > xMinPause {
                doPause()
            } else if p.x < xMaxHint{
                attemptHint()
            }
        }
    }
    
    func doPause() {
        let pauseScene = PauseScene(size: size, level: _level, playScene: self, timerCount: Int(ceil(_timerCount)))
        pauseScene.scaleMode = scaleMode
        view?.presentScene(pauseScene)
    }
    
    func attemptHint() {
        if _gameView.canHint() {
            Storage.addStars(-Constants.HINT_COST)
            updateStarLabel()
            _hintLabel.animate()
            _starLabel.animate()
            
            _gameView.hint()
            if !_gameView.canHint() {
                _hintLabel.disable()
            }
        } else {
//            _purchasePopup = PurchasePopup(parent: self)
//            refreshPurchasePopup()
//            _purchasePopup!.zPosition = 1000
//            _purchasePopup!.position = CGPoint(x: 0, y: -_purchasePopup!.frame.height)
//            addChild(_purchasePopup!)
//            _purchasePopup!.runAction(SKAction.moveToY(0, duration: 0.2), completion: {
//                self._purchasePopup?.activate()
//            })
        }
    }
    
    func closePurchasePopup() {
//        _purchasePopup!.runAction(SKAction.moveToY(-_purchasePopup!.frame.height, duration: 0.2), completion: {
//            self._purchasePopup!.removeFromParent()
//            self._purchasePopup = nil
//        })
    }
    
    func handleSwipeUp(sender: UITapGestureRecognizer) {
        _gameView.attemptMove(.Up, swipe: sender.location(in: sender.view))
    }
    
    func handleSwipeDown(sender: UITapGestureRecognizer) {
        _gameView.attemptMove(.Down, swipe: sender.location(in: sender.view))
    }
    
    func handleSwipeLeft(sender: UITapGestureRecognizer) {
        _gameView.attemptMove(.Left, swipe: sender.location(in: sender.view))
    }
    
    func handleSwipeRight(sender: UITapGestureRecognizer) {
        _gameView.attemptMove(.Right, swipe: sender.location(in: sender.view))
    }
    
    func handlePinch(sender: UIPinchGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.ended {
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
        let p = sender.location(in: sender.view)
        let x0 = p.x
        let y0 = size.height - p.y
        let x1 = _gameView.position.x
        let y1 = _gameView.position.y
        _gameView.position = CGPoint(x: x0 - (x0-x1) * (newScale/oldScale), y: y0 - (y0-y1) * (newScale/oldScale))
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.ended {
            bringBackToScreen()
            return
        }
        _bringingBack = false
        
        let v = sender.translation(in: sender.view)
        let p = _gameView.position
        _gameView.position = CGPoint(x: p.x + v.x, y: p.y - v.y)
        sender.setTranslation(CGPoint.zero, in: sender.view)
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
            _gameView.run(SKAction.moveBy(x: dX, y: dY, duration: 0.25), completion: { () -> Void in
                self._bringingBack = false
            })
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        var delta = currentTime
        if _prevUpdateTime != nil {
            delta -= _prevUpdateTime!
            _timerCount -= delta
            
            if _timerCount <= 0 {
                _gameView.resetBall(shouldKill: true, shouldCharge: true)
                _numTimerExpirations += 1
                _timerCount = Double(_timerTotal)
                _prevTick = _timerTotal + 1
            }
        }
        
        if Int(ceil(_timerCount)) < _prevTick {
            updateTimerLabel()
            _prevTick -= 1
        }
            
        if arc4random_uniform(200) == 0 {
            view?.layer.addSublayer(Trail(size: size))
        }
        
        _prevUpdateTime = currentTime
    }
    
    func updateStarLabel() {
        let text = "\(Storage.loadStars())"
        _starLabel.setText(text)
    }
    
    func updateTimerLabel() {
        let str = String(format:"%d:%02d", abs(Int(ceil(_timerCount))) / 60, abs(Int(ceil(_timerCount))) % 60)
        _timerLabel.text = str
        if _timerCount > 10 {
            _timerLabel.fontColor = UIColor.white
        } else {
            _timerLabel.fontColor = UIColor.red
        }
    }
    
    func complete() {
        let duration = (_numTimerExpirations * _timerTotal) + (_timerTotal - Int(ceil(_timerCount)))
        
        // Get old score before saving achievements to show which stars have already been earned
        let oldScore = Storage.loadScore(level: _level._level)
    
        // Record achievements and advance saved level counter
        let achievements = AchievementManager.recordLevelCompleted(level: _level, duration: duration, numTimerExpirations: _numTimerExpirations, didEnterVoid: _gameView._didEnterVoid)
        
        // Record stars earned
        let newScore = Storage.loadScore(level: _level._level)
        Storage.addStars(newScore - oldScore)
    
        let levelCompleteScene = LevelCompleteScene(size: size, level: _level, timerCount: Int(ceil(_timerCount)), duration: duration, achievements: achievements, oldScore: oldScore, newScore: newScore)
        levelCompleteScene.scaleMode = scaleMode
        AppDelegate.pushViewController(SKViewController(scene: levelCompleteScene), animated: true, offset: 0)
    }
    
    func refreshHUD() {
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        _starLabel.setSize(s * Constants.TEXT_SCALE)
        _starLabel.position = CGPoint(x: s * Constants.ICON_SCALE * 1.2, y: h - s * Constants.ICON_SCALE)
        
        _timerLabel.fontSize = s * Constants.TEXT_SCALE
        _timerLabel.position = CGPoint(x: w - s * Constants.TEXT_SCALE * 2, y: h - s * Constants.ICON_SCALE)
        
        let pauseSize = s * Constants.ICON_SCALE
        let pauseOffset = s * Constants.TEXT_SCALE
        _pauseButton.size = CGSize(width: pauseSize, height: pauseSize)
        _pauseButton.position = CGPoint(x: w - pauseOffset, y: pauseOffset)
        
        _hintLabel.setSize(s * Constants.TEXT_SCALE)
        _hintLabel.position = CGPoint(x: _starLabel.position.x, y: s * (Constants.ICON_SCALE - Constants.TEXT_SCALE))
    }
    
    func refreshStars() {
        let w = size.width
        let h = size.height
        
        if _starEmitter != nil {
            _starEmitter.particlePositionRange = CGVector(dx: w, dy: h)
            _starEmitter.position = CGPoint(x: w / 2, y: h / 2)
        }
    }
    
    func changedSize() {
        refreshHUD()
        refreshStars()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
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
