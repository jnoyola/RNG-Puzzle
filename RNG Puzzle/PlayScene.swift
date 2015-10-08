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
    
    var _tapRecognizer: UITapGestureRecognizer! = nil
    var _swipeUpRecognizer: UISwipeGestureRecognizer! = nil
    var _swipeDownRecognizer: UISwipeGestureRecognizer! = nil
    var _swipeLeftRecognizer: UISwipeGestureRecognizer! = nil
    var _swipeRightRecognizer: UISwipeGestureRecognizer! = nil
    var _pinchRecognizer: UIPinchGestureRecognizer! = nil
    var _panRecognizer: UIPanGestureRecognizer! = nil

    init(size: CGSize, level: Level) {
        super.init(size: size)
        _level = level
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMoveToView(view: SKView) {
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
        
        // Pan for panning
        _panRecognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        _panRecognizer.minimumNumberOfTouches = 2
        
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
    
    func handleSwipeUp(recognizer: UITapGestureRecognizer?) {
        print("swipe up")
    }
    
    func handleSwipeDown(recognizer: UITapGestureRecognizer?) {
        print("swipe down")
    }
    
    func handleSwipeLeft(recognizer: UITapGestureRecognizer?) {
        print("swipe left")
    }
    
    func handleSwipeRight(recognizer: UITapGestureRecognizer?) {
        print("swipe right")
    }
    
    func handlePinch(recognizer: UIPinchGestureRecognizer?) {
        print("pinch")
    }
    
    func handlePan(recognizer: UIPanGestureRecognizer?) {
        print("pan")
    }
}
