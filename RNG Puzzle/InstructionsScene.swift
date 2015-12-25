//
//  InstructionsScene.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 9/24/15.
//  Copyright © 2015 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit

class InstructionsScene: SKScene {

    var _title: SKLabelNode! = nil
    var _desc1: SKLabelNode! = nil
    var _desc2: SKLabelNode! = nil
    var _gameView: GameView? = nil
    var _finger1: Finger! = nil
    var _finger2: Finger! = nil
    var _pauseLabel: SKLabelNode! = nil
    var _codeLabel: SKLabelNode! = nil
    var _copyLabel1: SKLabelNode! = nil
    var _copyLabel2: SKLabelNode! = nil
    var _curStep = 0
    let _maxStep = 10
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor(red: 0.4, green: 0, blue: 0.4, alpha: 1)
        
        let height = size.height
        
        // Title (x of y)
        _title = addLabel("TITLE", size: height * 0.08, color: SKColor.whiteColor(), x: 0.5, y: 0.82)
        
        // < button
        addLabel("<", size: height * 0.1, color: SKColor.whiteColor(), x: 0.08, y: 0.465)
        
        // > button
        addLabel(">", size: height * 0.1, color: SKColor.whiteColor(), x: 0.918, y: 0.465)
        
        // Description
        _desc1 = addLabel("DESC", size: height * 0.064, color: SKColor.whiteColor(), x: 0.5, y: 0.18)
        _desc2 = addLabel("DESC", size: height * 0.064, color: SKColor.whiteColor(), x: 0.5, y: 0.07)
        
        // Paused
        _pauseLabel = addLabel("Paused", size: height * 0.064, color: SKColor.whiteColor(), x: 0.5, y: 0.465, z: 20, hidden: true)
        
        // Code
        _codeLabel = addLabel("Level 21", size: height * 0.08, color: SKColor.whiteColor(), x: 0.5, y: 0.5, z: 20, hidden: true)
        _copyLabel1 = addLabel("Copy Level ID", size: height * 0.04, color: SKColor.grayColor(), x: 0.5, y: 0.45, z: 20, hidden: true)
        _copyLabel2 = addLabel("Level ID Copied", size: height * 0.04, color: SKColor.grayColor(), x: 0.5, y: 0.45, z: 20, hidden: true)
        
        setStep(1)
    }
    
    func addLabel(text: String, size: CGFloat, color: SKColor, x: CGFloat, y: CGFloat, z: CGFloat = 0, hidden: Bool = false) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        label.text = text
        label.fontSize = size
        label.fontColor = color
        label.position = CGPointMake(self.size.width*x, self.size.height*y)
        label.zPosition = z
        label.horizontalAlignmentMode = .Center
        label.hidden = hidden
        self.addChild(label)
        return label
    }

    func setStep(step: Int) {
        _pauseLabel.hidden = true
        _codeLabel.hidden = true
        _copyLabel1.hidden = true
        _copyLabel2.hidden = true
        if (_gameView != nil) {
            _gameView!.removeFromParent()
            _gameView = nil
        }
        if (_finger1 != nil) {
            _finger1!.remove()
            _finger1 = nil
        }
        if (_finger2 != nil) {
            _finger2!.remove()
            _finger2 = nil
        }
        
        if (step == 0 || step > _maxStep) {
            let introScene = IntroScene(size: size)
            introScene.scaleMode = scaleMode
            view?.presentScene(introScene)
        }
        _curStep = step
        setStepText(step)
        setStepGame(step)
        performActionsForStep(step)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let p = touch.locationInNode(self)
        if (p.y > size.height * 0.35 && p.y < size.height * 0.65) {
            if (p.x < size.width * 0.25) {
                // <
                setStep(_curStep - 1)
            } else if (p.x > size.width * 0.75) {
                // >
                setStep(_curStep + 1)
            }
        }
    }
    
    func setStepText(step: Int) {
        var title: String! = nil
        var desc1 = ""
        var desc2 = ""
        switch (step) {
        case 1:
            title = "Goal"
            desc1 = "The goal of RNG Puzzle is to get the"
            desc2 = "blue and orange ball into the red portal."
        case 2:
            title = "Moving";
            desc1 = "Swipe one finger to move the ball"
            desc2 = "when it is not in motion."
        case 3:
            title = "The Void"
            desc1 = "If the ball enters the void,"
            desc2 = "the level will be reset."
        case 4:
            title = "Blocks";
            desc1 = "Blocks and walls stop the ball,"
            desc2 = "while corners redirect it."
        case 5:
            title = "Portals"
            desc1 = "Purple portals teleport the ball"
            desc2 = "to a new location."
        case 6:
            title = "Pausing"
            desc1 = "Tap to pause the game."
            break;
        case 7:
            title = "Zoom & Pan"
            desc1 = "Use two fingers to zoom and pan."
            break;
        case 8:
            title = "Levels"
            desc1 = "Levels are generated randomly"
            desc2 = "and will be different every time."
            break;
        case 9:
            title = "Level ID"
            desc1 = "An ID for each level is displayed at"
            desc2 = "the Pause and Level Complete screens."
            _codeLabel.hidden = false
            _copyLabel1.hidden = false
        case 10:
            title = "Level ID"
            desc1 = "Share this code with friends to"
            desc2 = "challenge them to the same level!"
            _codeLabel.hidden = false
            _copyLabel2.hidden = false
        default:
            break
        }
        _title.text = "\(title) (\(_curStep) of \(_maxStep))"
        _desc1.text = desc1
        _desc2.text = desc2
    }
    
    func setStepGame(step: Int) {
        let level = Level(instruction: step)
        _gameView = GameView(level: level, playScene: self, winCallback: nil)
        _gameView!.setBaseScale(_gameView!._baseScale * 0.6)
        _gameView!.position = CGPoint(x: (size.width - _gameView!.getWidth()) / 2, y: (size.height - _gameView!.getHeight()) / 2)
        addChild(_gameView!)
    }
    
    func performActionsForStep(step: Int) {
        switch (step) {
        case 2:
            startSwipeRight()
        case 3:
            startSwipeRight()
        case 4:
            startSwipeCombo()
        case 5: 
            startSwipeRight()
        case 6:
            startTap()
        case 7:
            startPinchPan()
        default:
            break
        }
    }
    
    func startSwipeRight() {
        _finger1 = Finger(x: size.width * 0.25, y: size.height * 0.32, z: 15, parent: self)
        dispatch_async(dispatch_get_main_queue(), {
            self.swipeRight_1()
        })
    }
    func startSwipeCombo() {
        _finger1 = Finger(x: size.width * 0.3, y: size.height * 0.5, z: 15, parent: self)
        dispatch_async(dispatch_get_main_queue(), {
            self.swipeCombo_1()
        })
    }
    func startTap() {
        _finger1 = Finger(x: size.width * 0.5, y: size.height * 0.32, z: 15, parent: self)
        dispatch_async(dispatch_get_main_queue(), {
            self.tap_1()
        })
    }
    func startPinchPan() {
        _finger1 = Finger(x: size.width * 0.25, y: size.height * 0.32, z: 15, parent: self)
        _finger2 = Finger(x: size.width * 0.75, y: size.height * 0.32, z: 15, parent: self)
        dispatch_async(dispatch_get_main_queue(), {
            self.pinch1_1()
            self.pinch2_1()
        })
    }
    
    
    func swipeRight_1() {
        _finger1.animateTo(x: _finger1._x, y: _finger1._y, z: 0, duration: 0.5, callback: swipeRight_2)
    }
    func swipeRight_2() {
        let x = _finger1._x + size.width / 8
        _finger1.animateTo(x: x, y: _finger1._y, z: 0, duration: 0.2, callback: swipeRight_3)
        _gameView!.attemptMove(.Right, swipe: CGPoint(x: _finger1._x, y: _finger1._y))
    }
    func swipeRight_3() {
        let x = _finger1._x + size.width / 8
        _finger1.animateTo(x: x, y: _finger1._y, z: 30, duration: 0.2, callback: swipeRight_4)
    }
    func swipeRight_4() {
        let x = size.width * 0.25
        let y = size.height * 0.32
        _finger1.animateTo(x: x, y: y, z: 15, duration: 0.5, callback: swipeRight_1)
    }
    
    
    func swipeCombo_1() {
        _finger1.animateTo(x: _finger1._x, y: _finger1._y, z: 0, duration: 0.5, callback: swipeCombo_2)
    }
    func swipeCombo_2() {
        let x = _finger1._x + size.width / 8
        _finger1.animateTo(x: x, y: _finger1._y, z: 0, duration: 0.2, callback: swipeCombo_3)
        _gameView!.attemptMove(.Right, swipe: CGPoint(x: _finger1._x, y: _finger1._y))
    }
    func swipeCombo_3() {
        let x = _finger1._x + size.width / 8
        _finger1.animateTo(x: x, y: _finger1._y, z: 30, duration: 0.2, callback: swipeCombo_4)
    }
    func swipeCombo_4() {
        let x = size.width * 0.3
        let y = size.height * 0.5
        _finger1.animateTo(x: x, y: y, z: 15, duration: 0.5, callback: swipeCombo_5)
    }
    func swipeCombo_5() {
        _finger1.animateTo(x: _finger1._x, y: _finger1._y, z: 0, duration: 0.5, callback: swipeCombo_6)
    }
    func swipeCombo_6() {
        let y = _finger1._y - size.height / 8
        _finger1.animateTo(x: _finger1._x, y: y, z: 0, duration: 0.2, callback: swipeCombo_7)
        _gameView!.attemptMove(.Down, swipe: CGPoint(x: _finger1._x, y: _finger1._y))
    }
    func swipeCombo_7() {
        let y = _finger1._y - size.height / 8
        _finger1.animateTo(x: _finger1._x, y: y, z: 30, duration: 0.2, callback: swipeCombo_8)
    }
    func swipeCombo_8() {
        let x = size.width * 0.3
        let y = size.height * 0.5
        _finger1.animateTo(x: x, y: y, z: 15, duration: 0.5, callback: swipeCombo_9)
    }
    func swipeCombo_9() {
        _finger1.animateTo(x: _finger1._x, y: _finger1._y, z: 0, duration: 0.5, callback: swipeCombo_10)
    }
    func swipeCombo_10() {
        let y = _finger1._y + size.height / 8
        _finger1.animateTo(x: _finger1._x, y: y, z: 0, duration: 0.2, callback: swipeCombo_11)
        _gameView!.attemptMove(.Up, swipe: CGPoint(x: _finger1._x, y: _finger1._y))
    }
    func swipeCombo_11() {
        let y = _finger1._y + size.height / 8
        _finger1.animateTo(x: _finger1._x, y: y, z: 30, duration: 0.2, callback: swipeCombo_12)
    }
    func swipeCombo_12() {
        let x = size.width * 0.3
        let y = size.height * 0.5
        _finger1.animateTo(x: x, y: y, z: 15, duration: 0.5, callback: swipeCombo_1)
    }
    
    
    func tap_1() {
        _finger1.animateTo(x: _finger1._x, y: _finger1._y, z: 0, duration: 0.5, callback: tap_2)
    }
    func tap_2() {
        _finger1.animateTo(x: _finger1._x, y: _finger1._y, z: 15, duration: 0.5, callback: tap_1)
        _pauseLabel.hidden = !_pauseLabel.hidden
    }
    
    func pinch1_1() {
        _finger1.animateTo(x: _finger1._x, y: _finger1._y, z: 0, duration: 0.5, callback: pinch1_2)
    }
    func pinch1_2() {
        let x = _finger1._x + size.width * 0.15
        _finger1.animateTo(x: x, y: _finger1._y, z: 0, duration: 0.5, callback: pan1_1)
        
        let targetScale: CGFloat = 0.5
        let startScale = _gameView!._scale
        let scaleFactor = targetScale / startScale
        let duration: Double = 0.5
        
        _gameView!.runAction(SKAction.moveTo(CGPoint(x: (size.width - _gameView!.getWidth() * scaleFactor) / 2, y: (size.height - _gameView!.getHeight() * scaleFactor) / 2), duration: duration))
        _gameView!.runAction(SKAction.customActionWithDuration(duration, actionBlock:
            { (node: SKNode, elapsedTime: CGFloat) -> Void in
                let scale = elapsedTime / CGFloat(duration) * (targetScale - startScale) + startScale
                self._gameView!.setScale(scale)
            }
        ))
    }
    func pan1_1() {
        let dy = size.height * 0.2
        _finger1.animateTo(x: _finger1._x, y: _finger1._y + dy, z: 0, duration: 0.5, callback: pan1_2)
        
        _gameView!.runAction(SKAction.moveByX(0, y: dy, duration: 0.5))
    }
    func pan1_2() {
        _finger1.animateTo(x: _finger1._x, y: _finger1._y, z: 15, duration: 0.5, callback: pinch1_3)
    }
    func pinch1_3() {
        _finger1.animateTo(x: _finger1._x, y: _finger1._y, z: 0, duration: 0.5, callback: pinch1_4)
    }
    func pinch1_4() {
        let x = _finger1._x - size.width * 0.15
        _finger1.animateTo(x: x, y: _finger1._y, z: 0, duration: 0.5, callback: pan1_3)
        
        let targetScale: CGFloat = 1.0
        let startScale = _gameView!._scale
        let duration: Double = 0.5
        
        _gameView!.runAction(SKAction.moveTo(CGPoint(x: _gameView!.position.x - _gameView!.getWidth() / 2, y: _gameView!.position.y - _gameView!.getHeight() / 2), duration: duration))
        _gameView!.runAction(SKAction.customActionWithDuration(duration, actionBlock:
            { (node: SKNode, elapsedTime: CGFloat) -> Void in
                let scale = elapsedTime / CGFloat(duration) * (targetScale - startScale) + startScale
                self._gameView!.setScale(scale)
            }
        ))
    }
    func pan1_3() {
        let dy = -size.height * 0.2
        _finger1.animateTo(x: _finger1._x, y: _finger1._y + dy, z: 0, duration: 0.5, callback: pan1_4)
        
        _gameView!.runAction(SKAction.moveByX(0, y: dy, duration: 0.5))
    }
    func pan1_4() {
        _finger1.animateTo(x: _finger1._x, y: _finger1._y, z: 15, duration: 0.5, callback: pinch1_1)
    }
    
    
    func pinch2_1() {
        _finger2.animateTo(x: _finger2._x, y: _finger2._y, z: 0, duration: 0.5, callback: pinch2_2)
    }
    func pinch2_2() {
        let x = _finger2._x - size.width * 0.15
        _finger2.animateTo(x: x, y: _finger2._y, z: 0, duration: 0.5, callback: pan2_1)
    }
    func pan2_1() {
        let y = _finger2._y + size.height * 0.2
        _finger2.animateTo(x: _finger2._x, y: y, z: 0, duration: 0.5, callback: pan2_2)
    }
    func pan2_2() {
        _finger2.animateTo(x: _finger2._x, y: _finger2._y, z: 15, duration: 0.5, callback: pinch2_3)
    }
    func pinch2_3() {
        _finger2.animateTo(x: _finger2._x, y: _finger2._y, z: 0, duration: 0.5, callback: pinch2_4)
    }
    func pinch2_4() {
        let x = _finger2._x + size.width * 0.15
        _finger2.animateTo(x: x, y: _finger2._y, z: 0, duration: 0.5, callback: pan2_3)
    }
    func pan2_3() {
        let y = _finger2._y - size.height * 0.2
        _finger2.animateTo(x: _finger2._x, y: y, z: 0, duration: 0.5, callback: pan2_4)
    }
    func pan2_4() {
        _finger2.animateTo(x: _finger2._x, y: _finger2._y, z: 15, duration: 0.5, callback: pinch2_1)
    }
}
