//
//  LevelSelectScene.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 9/24/15.
//  Copyright © 2015 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit

class LevelSelectScene: SKScene, UITextFieldDelegate, UIGestureRecognizerDelegate, Refreshable {

    var _titleLabel: SKLabelNode! = nil
    var _backLabel: SKLabelNode! = nil
    var _playLabel: SKLabelNode! = nil
    var _textInput: UITextField? = nil
    var _planetarium: Planetarium! = nil
    var _starLabel: StarLabel? = nil
    
    var _isPanning = false
    var _panRecognizer: UIPanGestureRecognizer! = nil
    var _prevUpdateTime: CFTimeInterval? = nil
    var _vx: CGFloat = 0
    let _vLimit: CGFloat = 15
    
    var _holdTimer: NSTimer? = nil
    var _justHeld = false
    var _grayOut: SKShapeNode! = nil

    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        let maxLevel = Storage.loadMaxLevel()
        
        // Title
        _titleLabel = addLabel("Select Level", color: Constants.TITLE_COLOR)
        
        // Back
        _backLabel = addLabel("Back", color: SKColor.whiteColor())
        
        // Play
        _playLabel = addLabel("Play", color: SKColor.whiteColor())
        
        // Text Input
        _textInput = UITextField.init()
        _textInput!.backgroundColor = UIColor.whiteColor()
        _textInput!.textAlignment = .Center
        _textInput!.contentVerticalAlignment = .Bottom
        _textInput!.keyboardType = .DecimalPad
        _textInput!.autocorrectionType = .No
        _textInput!.placeholder = "Level"
        _textInput!.text = String(maxLevel)
        _textInput!.delegate = self
        view.addSubview(self._textInput!)
        
        // Planetarium
        createPlanetarium(maxLevel)
        
        // Star Label
        createStarLabel()
        
        // Gray Out (for planet samples)
        _grayOut = SKShapeNode()
        _grayOut.lineWidth = 0
        _grayOut.fillColor = SKColor.blackColor()
        _grayOut.alpha = 0.8
        _grayOut.zPosition = 99
        _grayOut.hidden = true
        addChild(_grayOut)
        
        _panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        _panRecognizer.delegate = self
        view.addGestureRecognizer(_panRecognizer)
    
        refreshLayout()
    }
    
    func createPlanetarium(maxLevel: Int) {
        _planetarium = Planetarium()
        addChild(_planetarium)
    }
    
    func createStarLabel() {
        _starLabel = StarLabel(text: "\(Storage.loadStars())", color: SKColor.whiteColor(), anchor: .Left)
        addChild(_starLabel!)
    }
    
    func refresh() {
        _planetarium.refreshPlanets(size)
    }
    
    override func willMoveFromView(view: SKView) {
        _prevUpdateTime = nil
        
        _textInput?.removeFromSuperview()
        
        view.removeGestureRecognizer(_panRecognizer)
    }
    
    func addLabel(text: String, color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: Constants.FONT)
        label.text = text
        label.fontColor = color
        self.addChild(label)
        return label
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        _textInput?.resignFirstResponder()
        _planetarium.hideSample()
        _grayOut.hidden = true
        _textInput?.backgroundColor = UIColor.whiteColor()
        
        let p = touches.first!.locationInNode(self)
        if p.y < _planetarium.position.y * 2 {
            _vx = 0
            _planetarium.hideMarkers(false, speed: 0)
        }
        
        _holdTimer?.invalidate()
        _holdTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(completeHold), userInfo: NSValue(CGPoint: p), repeats: false)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        cancelHold()
        if _justHeld {
            _justHeld = false
            return
        }
    
        let touch = touches.first!
        let p = touch.locationInNode(self)
        let w = size.width
        let h = size.height
        if p.y > h * 0.56 && p.y < h * 0.76 {
            if (p.x < w * 0.25) {
                back()
            } else if (p.x > w * 0.75) {
                play()
            }
        } else if p.y < _planetarium!.position.y * 2 && !_isPanning {
            let levelNum = _planetarium.tap(p)
            if levelNum != nil && levelNum <= getMaxAllowedLevel() {
                if levelNum! > 0 {
                    _textInput?.text = String(levelNum!)
                }
                _planetarium.selectLevel(levelNum!)
            }
        }
    }
    
    func cancelHold() {
        _holdTimer?.invalidate()
        _holdTimer = nil
    }
    
    func completeHold(timer: NSTimer) {
        let p = (timer.userInfo as! NSValue).CGPointValue()
        _holdTimer = nil
        _justHeld = true
        if _planetarium.hold(p) {
            _grayOut.hidden = false
            _textInput?.backgroundColor = UIColor.darkGrayColor()
        }
    }
    
    func back() {
        AppDelegate.popViewController(animated: true)
    }
    
    func play() {
        let level = LevelParser.parse(_textInput!.text!, allowGenerated: true, allowCustom: true)
        if (level != nil) {
            let generationScene = LevelGenerationScene(size: size, level: level!)
            AppDelegate.pushViewController(SKViewController(scene: generationScene), animated: true, offset: 1)
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
//        for c in string.characters {
//            if (c < "0" || c > "9") && c != "." {
//                return false
//            }
//        }
        
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        let tokens = newString.componentsSeparatedByString(".")
        let levelNum = (tokens[0] as NSString).integerValue
        let levelMax = getMaxAllowedLevel()
        if levelNum > levelMax {
            textField.text = String(levelMax)
            _planetarium.selectLevel(levelMax)
            return false
        }
        _planetarium.selectLevel(levelNum)
        return true
    }
    
    func getMaxAllowedLevel() -> Int {
        return Storage.loadMaxLevel()
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        cancelHold()
        if _justHeld {
            if sender.state == .Ended {
                _justHeld = false
            }
            return
        }
    
        _vx = 0
        let translation = sender.translationInView(sender.view)
        _planetarium.translate(translation.x)
        
        if sender.state == .Began {
            _isPanning = true
        } else if sender.state == .Ended {
            _isPanning = false
            _vx = sender.velocityInView(sender.view).x
        }
        
        sender.setTranslation(CGPointZero, inView: self.view)
    }
    
    override func update(currentTime: NSTimeInterval) {
        var delta = currentTime
        if _prevUpdateTime != nil {
            delta -= _prevUpdateTime!
            _vx *= 0.98
            
            var speed: CGFloat = 0
            if abs(_vx) > 0.1 {
                speed = abs(_planetarium.translate(CGFloat(delta) * _vx))
            } else {
                _vx = 0
            }
            
            if speed > _vLimit && !_planetarium._markersHidden {
                _planetarium.hideMarkers(true, speed: speed)
            } else if speed <= _vLimit && _planetarium._markersHidden {
                _planetarium.hideMarkers(false, speed: speed)
            }
        }
        
        _prevUpdateTime = currentTime
    }
    
    func refreshLayout() {
        if _titleLabel == nil {
            return
        }
    
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        _titleLabel.fontSize = s * Constants.TITLE_SCALE
        _titleLabel.position = CGPoint(x: w * 0.5, y: h * 0.85)
        
        _backLabel.fontSize = s * Constants.TEXT_SCALE
        _backLabel.position = CGPoint(x: w * 0.15, y: h * 0.69 - s * Constants.TEXT_SCALE * 0.4)
        
        _playLabel.fontSize = s * Constants.TEXT_SCALE
        _playLabel.position = CGPoint(x: w * 0.85, y: h * 0.69 - s * Constants.TEXT_SCALE * 0.4)
        
        let inputWidth: CGFloat = 200.0/480.0 * w
        let inputHeight: CGFloat = s * Constants.TEXT_SCALE * 1.25
        let inputX = 0.5 * w - inputWidth / 2
        let inputY = 0.31 * h - inputHeight / 2
        _textInput?.frame = CGRect(x: inputX, y: inputY, width: inputWidth, height: inputHeight)
        _textInput?.font = UIFont(name: Constants.FONT, size: s * Constants.TEXT_SCALE)
        
        _planetarium.refreshLayout(size)
        _planetarium.position.y = h * 0.32
        
        _starLabel?.setSize(s * Constants.TEXT_SCALE)
        _starLabel?.position = CGPoint(x: s * Constants.ICON_SCALE * 1.2, y: h - s * Constants.ICON_SCALE)
        
        _grayOut.path = CGPathCreateWithRect(frame, nil)
    }
    
    override func didChangeSize(oldSize: CGSize) {
        refreshLayout()
    }
}
