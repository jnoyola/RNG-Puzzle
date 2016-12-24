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

    var _gameView: GameView? = nil
    var _finger1: Finger! = nil
    var _finger2: Finger! = nil
    var _pauseLabel: SKLabelNode! = nil
    var _curStep = 1
    let _maxStep = 13
    
    let dx: CGFloat = 50
    
    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        setStep(1)
    }
    
    func addLabel(text: String, color: SKColor, fontSize: CGFloat, x: CGFloat, y: CGFloat, z: CGFloat = 0, hidden: Bool = false) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: Constants.FONT)
        label.text = text
        label.fontColor = color
        label.fontSize = fontSize
        label.position = CGPoint(x: x, y: y)
        label.zPosition = z
        label.horizontalAlignmentMode = .Center
        label.hidden = hidden
        self.addChild(label)
        return label
    }
    
    override func didChangeSize(oldSize: CGSize) {
        setStep(_curStep)
    }

    func setStep(step: Int) {
        if step == 0 || step > _maxStep {
            AppDelegate.popViewController(animated: true)
            return
        }
        
        if _gameView != nil {
            _gameView!._ball.stopIdleTimer()
        }
        
        if _finger1 != nil {
            _finger1.remove()
        }
        if _finger2 != nil {
            _finger2.remove()
        }
        
        self.removeAllChildren()
        
        _curStep = step
        setStepGame(step)
        setStepElements(step)
        performActionsForStep(step)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
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
    
    func setStepElements(step: Int) {
        var title: String! = nil
        var descText: String! = nil
        var copyText: String? = nil
        var timed = false
        var paused = false
        var showLevelID = false
        switch (step) {
        case 1:
            title = "Goal"
            descText = "Help Astro find his way home through the galaxy"
        case 2:
            title = "Moving";
            descText = "Swipe to move when he's at rest"
        case 3:
            title = "The Void"
            descText = "Don't go off the edge into the void"
        case 4:
            title = "Blocks";
            descText = "Astro will keep moving until he hits a wall"
        case 5:
            title = "Wormholes"
            descText = "Purple wormholes teleport him to a new location"
        case 6:
            title = "Timer"
            descText = "Don't let time run out"
            timed = true
        case 7:
            title = "Hints"
            descText = "Use hints if you get stuck"
        case 8:
            title = "Pausing"
            descText = "Tap to pause the game"
            paused = true
            break;
        case 9:
            title = "Zoom & Pan"
            descText = "Use two fingers to zoom and pan"
            break;
        case 10:
            title = "Puzzles"
            descText = "Millions of unique puzzles are randomly generated"
            break;
        case 11:
            title = "Creation"
            descText = "You can also create your own puzzles to share with friends"
            break;
        case 12:
            title = "Level ID"
            descText = "An ID for each level shows the difficulty and seed"
            copyText = "Copy Level ID"
            showLevelID = true
        case 13:
            title = "Sharing"
            descText = "Share these codes with friends to challenge them to the same level!"
            copyText = "Level ID Copied"
            showLevelID = true
        default:
            break
        }
        let titleText = "\(_curStep) of \(_maxStep)\n\(title)"
        
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        // Title
        let titleLabel = SKMultilineLabel(text: titleText, labelWidth: w * 0.9, pos: CGPoint(x: w * 0.5, y: (3 * h + _gameView!.getHeight()) / 4), fontName: Constants.FONT, fontSize: s * Constants.TITLE_SCALE, fontColor: Constants.TITLE_COLOR, spacing: 1.25, alignment: .Center, shouldShowBorder: false)
        addChild(titleLabel)
        
        // < button
        addLabel("<", color: SKColor.whiteColor(), fontSize: s * 0.1, x: w * 0.1, y: h * 0.5 - s * 0.04)
        
        // > button
        addLabel(">", color: SKColor.whiteColor(), fontSize: s * 0.1, x: w * 0.898, y: h * 0.5 - s * 0.04)
        
        // Paused
        if paused {
            _pauseLabel = addLabel("Paused", color: SKColor.whiteColor(), fontSize: s * Constants.TEXT_SCALE, x: w * 0.5, y: h * 0.5 - s * Constants.TEXT_SCALE * 0.4, z: 20, hidden: true)
        } else if timed {
            _pauseLabel = addLabel("0:30", color: SKColor.whiteColor(), fontSize: s * Constants.TEXT_SCALE, x: w * 0.5, y: h * 0.5 - s * Constants.TEXT_SCALE * 0.4, z: 20)
        }

        // Copy Label
        if copyText != nil {
            addLabel(copyText!, color: SKColor.grayColor(), fontSize: s * 0.04, x: w * 0.5, y: h * 0.49 - s * 0.05, z: 20)
        }
        
        // Description
        let descLabel = SKMultilineLabel(text: descText, labelWidth: w * 0.9, pos: CGPoint(x: w * 0.5, y: (h - _gameView!.getHeight()) / 4), fontName: Constants.FONT, fontSize: s * Constants.TEXT_SCALE * 0.75, fontColor: SKColor.whiteColor(), spacing: 1.5, alignment: .Center, shouldShowBorder: false)
        addChild(descLabel)
        
        // Level ID
        if showLevelID {
            let codeLabel = LevelLabel(level: 21, seed: "3194", size: s * 0.08, color: SKColor.whiteColor())
            codeLabel.position = CGPointMake(w * 0.5, h * 0.49)
            codeLabel.zPosition = 20
            addChild(codeLabel)
        }
    }
    
    func setStepGame(step: Int) {
        let level = Level(instruction: step)
        if step == 11 {
            _gameView = CreationView(level: level, parent: self, winCallback: nil)
            (_gameView as! CreationView)._selectedPoint = (x: 4, y: 1)
            (_gameView as! CreationView).markSelected()
        } else {
            _gameView = GameView(level: level, parent: self, winCallback: nil)
            if step == 7 {
                _gameView!.hint()
                _gameView!.hint()
            }
        }
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
        case 8:
            startTap()
        case 9:
            startPinchPan()
        default:
            break
        }
    }
    
    func startSwipeRight() {
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        _finger1 = Finger(x: w * 0.25, y: h * 0.5 - s * 0.15, z: 15, parent: self)
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
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        _finger1 = Finger(x: w * 0.5, y: h * 0.5 - s * 0.15, z: 15, parent: self)
        dispatch_async(dispatch_get_main_queue(), {
            self.tap_1()
        })
    }
    func startPinchPan() {
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        _finger1 = Finger(x: w * 0.25, y: h * 0.5 - s * 0.15, z: 15, parent: self)
        _finger2 = Finger(x: w * 0.75, y: h * 0.5 - s * 0.15, z: 15, parent: self)
        dispatch_async(dispatch_get_main_queue(), {
            self.pinch1_1()
            self.pinch2_1()
        })
    }
    
    
    func swipeRight_1() {
        _finger1.animateTo(x: _finger1._x, y: _finger1._y, z: 0, duration: 0.5, callback: swipeRight_2)
    }
    func swipeRight_2() {
        let x = _finger1._x + dx
        _finger1.animateTo(x: x, y: _finger1._y, z: 0, duration: 0.2, callback: swipeRight_3)
        _gameView!.attemptMove(.Right, swipe: CGPoint(x: _finger1._x, y: _finger1._y))
    }
    func swipeRight_3() {
        let x = _finger1._x + dx
        _finger1.animateTo(x: x, y: _finger1._y, z: 30, duration: 0.2, callback: swipeRight_4)
    }
    func swipeRight_4() {
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        let x = w * 0.25
        let y = h * 0.5 - s * 0.15
        _finger1.animateTo(x: x, y: y, z: 15, duration: 1, callback: swipeRight_1)
    }
    
    
    func swipeCombo_1() {
        _finger1.animateTo(x: _finger1._x, y: _finger1._y, z: 0, duration: 0.5, callback: swipeCombo_2)
    }
    func swipeCombo_2() {
        let x = _finger1._x + dx
        _finger1.animateTo(x: x, y: _finger1._y, z: 0, duration: 0.2, callback: swipeCombo_3)
        _gameView!.attemptMove(.Right, swipe: CGPoint(x: _finger1._x, y: _finger1._y))
    }
    func swipeCombo_3() {
        let x = _finger1._x + dx
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
        let y = _finger1._y - dx
        _finger1.animateTo(x: _finger1._x, y: y, z: 0, duration: 0.2, callback: swipeCombo_7)
        _gameView!.attemptMove(.Down, swipe: CGPoint(x: _finger1._x, y: _finger1._y))
    }
    func swipeCombo_7() {
        let y = _finger1._y - dx
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
        let y = _finger1._y + dx
        _finger1.animateTo(x: _finger1._x, y: y, z: 0, duration: 0.2, callback: swipeCombo_11)
        _gameView!.attemptMove(.Up, swipe: CGPoint(x: _finger1._x, y: _finger1._y))
    }
    func swipeCombo_11() {
        let y = _finger1._y + dx
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
        let x = _finger1._x + size.width / 8
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
        _finger1.animateTo(x: _finger1._x, y: _finger1._y + dx, z: 0, duration: 0.5, callback: pan1_2)
        
        _gameView!.runAction(SKAction.moveByX(0, y: dx, duration: 0.5))
    }
    func pan1_2() {
        _finger1.animateTo(x: _finger1._x, y: _finger1._y, z: 15, duration: 0.5, callback: pinch1_3)
    }
    func pinch1_3() {
        _finger1.animateTo(x: _finger1._x, y: _finger1._y, z: 0, duration: 0.5, callback: pinch1_4)
    }
    func pinch1_4() {
        let x = _finger1._x - size.width / 8
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
        _finger1.animateTo(x: _finger1._x, y: _finger1._y - dx, z: 0, duration: 0.5, callback: pan1_4)
        
        _gameView!.runAction(SKAction.moveByX(0, y: -dx, duration: 0.5))
    }
    func pan1_4() {
        _finger1.animateTo(x: _finger1._x, y: _finger1._y, z: 15, duration: 0.5, callback: pinch1_1)
    }
    
    
    func pinch2_1() {
        _finger2.animateTo(x: _finger2._x, y: _finger2._y, z: 0, duration: 0.5, callback: pinch2_2)
    }
    func pinch2_2() {
        let x = _finger2._x - size.width / 8
        _finger2.animateTo(x: x, y: _finger2._y, z: 0, duration: 0.5, callback: pan2_1)
    }
    func pan2_1() {
        let y = _finger2._y + dx
        _finger2.animateTo(x: _finger2._x, y: y, z: 0, duration: 0.5, callback: pan2_2)
    }
    func pan2_2() {
        _finger2.animateTo(x: _finger2._x, y: _finger2._y, z: 15, duration: 0.5, callback: pinch2_3)
    }
    func pinch2_3() {
        _finger2.animateTo(x: _finger2._x, y: _finger2._y, z: 0, duration: 0.5, callback: pinch2_4)
    }
    func pinch2_4() {
        let x = _finger2._x + size.width / 8
        _finger2.animateTo(x: x, y: _finger2._y, z: 0, duration: 0.5, callback: pan2_3)
    }
    func pan2_3() {
        let y = _finger2._y - dx
        _finger2.animateTo(x: _finger2._x, y: y, z: 0, duration: 0.5, callback: pan2_4)
    }
    func pan2_4() {
        _finger2.animateTo(x: _finger2._x, y: _finger2._y, z: 15, duration: 0.5, callback: pinch2_1)
    }
}
