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
    
    var _holdTimer: Timer? = nil
    var _justHeld = false
    var _justClosedSample = false
    var _grayOut: SKShapeNode! = nil

    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        let maxLevel = Storage.loadMaxLevel()
        
        // Title
        _titleLabel = addLabel("Select Level", color: Constants.TITLE_COLOR)
        
        // Back
        _backLabel = addLabel("Back", color: SKColor.white)
        
        // Play
        _playLabel = addLabel("Play", color: SKColor.white)
        
        // Text Input
        _textInput = TextField.init()
        _textInput!.textColor = UIColor.white
        _textInput!.tintColor = UIColor.white
        _textInput!.backgroundColor = UIColor.clear
        _textInput!.layer.borderColor = Constants.TITLE_COLOR.cgColor
        _textInput!.textAlignment = .center
        _textInput!.contentVerticalAlignment = .bottom
        _textInput!.keyboardType = .decimalPad
        _textInput!.autocorrectionType = .no
        _textInput!.attributedPlaceholder = NSAttributedString(string: "Level", attributes: [NSForegroundColorAttributeName: UIColor.gray])
        _textInput!.text = String(maxLevel)
        _textInput!.delegate = self
        view.addSubview(self._textInput!)
        
        // Planetarium
        createPlanetarium(maxLevel: maxLevel)
        
        // Star Label
        createStarLabel()
        
        // Gray Out (for planet samples)
        _grayOut = SKShapeNode()
        _grayOut.lineWidth = 0
        _grayOut.fillColor = SKColor.black
        _grayOut.alpha = 0.8
        _grayOut.zPosition = 99
        _grayOut.isHidden = true
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
        _starLabel = StarLabel(text: "\(Storage.loadStars())", color: SKColor.white, anchor: .left)
        addChild(_starLabel!)
    }
    
    func refresh() {
        _planetarium.refreshPlanets(size: size)
        _starLabel?.setText("\(Storage.loadStars())")
    }
    
    override func willMove(from view: SKView) {
        _prevUpdateTime = nil
        
        _textInput?.removeFromSuperview()
        
        view.removeGestureRecognizer(_panRecognizer)
    }
    
    func addLabel(_ text: String, color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: Constants.FONT)
        label.text = text
        label.fontColor = color
        self.addChild(label)
        return label
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        _textInput?.resignFirstResponder()
        
        if !_grayOut.isHidden {
            _planetarium.hideSample()
            _grayOut.isHidden = true
            _textInput?.textColor = UIColor.white
            _textInput?.layer.borderColor = Constants.TITLE_COLOR.cgColor
            _justClosedSample = true
        } else {
            let p = touches.first!.location(in: self)
            if p.y < _planetarium.position.y * 2 {
                _vx = 0
                _planetarium.hideMarkers(false, speed: 0)
            }
        
            _holdTimer?.invalidate()
            _holdTimer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: #selector(completeHold), userInfo: NSValue(cgPoint: p), repeats: false)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        cancelHold()
        if _justHeld {
            _justHeld = false
            return
        }
        if _justClosedSample {
            _justClosedSample = false
            return
        }
    
        let touch = touches.first!
        let p = touch.location(in: self)
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
            if levelNum != nil && levelNum! <= getMaxAllowedLevel() {
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
    
    func completeHold(timer: Timer) {
        let p = (timer.userInfo as! NSValue).cgPointValue
        _holdTimer = nil
        if _planetarium.hold(p) {
            _justHeld = true
            _grayOut.isHidden = false
            _textInput?.textColor = UIColor.darkGray
            _textInput?.layer.borderColor = UIColor(red: 0, green: 0.2, blue: 0.2, alpha: 1.0).cgColor
        }
    }
    
    func back() {
        AppDelegate.popViewController(animated: true)
    }
    
    func play() {
        let level = LevelParser.parse(code: _textInput!.text!, allowGenerated: true, allowCustom: true)
        if (level != nil) {
            let generationScene = LevelGenerationScene(size: size, level: level!)
            AppDelegate.pushViewController(SKViewController(scene: generationScene), animated: true, offset: 1)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        for c in string.characters {
//            if (c < "0" || c > "9") && c != "." {
//                return false
//            }
//        }
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        let tokens = newString.components(separatedBy: ".")
        let levelNum = (tokens[0] as NSString).integerValue
        let levelMax = getMaxAllowedLevel()
        // TODO: CHANGE BACK
//        if levelNum > levelMax {
//            textField.text = String(levelMax)
//            _planetarium.selectLevel(levelMax)
//            return false
//        }
        _planetarium.selectLevel(levelNum)
        return true
    }
    
    func getMaxAllowedLevel() -> Int {
        return Storage.loadMaxLevel()
    }
    
    func handlePan(sender: UIPanGestureRecognizer) {
        cancelHold()
        if _justHeld {
            if sender.state == .ended {
                _justHeld = false
            }
            return
        }
    
        _vx = 0
        let translation = sender.translation(in: sender.view)
        let _ = _planetarium.translate(dx: translation.x)
        
        if sender.state == .began {
            _isPanning = true
        } else if sender.state == .ended {
            _isPanning = false
            _vx = sender.velocity(in: sender.view).x
        }
        
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    override func update(_ currentTime: TimeInterval) {
        var delta = currentTime
        if _prevUpdateTime != nil {
            delta -= _prevUpdateTime!
            _vx *= 0.98
            
            var speed: CGFloat = 0
            if abs(_vx) > 0.1 {
                speed = abs(_planetarium.translate(dx: CGFloat(delta) * _vx))
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
        
        if _textInput != nil {
            let inputWidth: CGFloat = s * 200.0/480.0
            let inputHeight: CGFloat = s * Constants.TEXT_SCALE * 1.5
            let inputX = 0.5 * w - inputWidth / 2
            let inputY = 0.31 * h - inputHeight / 2
            _textInput!.frame = CGRect(x: inputX, y: inputY, width: inputWidth, height: inputHeight)
            _textInput!.font = UIFont(name: Constants.FONT, size: s * Constants.TEXT_SCALE)
            
            let thickness: CGFloat = inputHeight * 0.05
            _textInput!.layer.borderWidth = thickness
            _textInput!.layer.cornerRadius = thickness * 4
        }
        
        _planetarium.refreshLayout(size: size)
        _planetarium.position.y = h * 0.32
        
        _starLabel?.setSize(s * Constants.TEXT_SCALE)
        _starLabel?.position = CGPoint(x: s * Constants.ICON_SCALE * 1.2, y: h - s * Constants.ICON_SCALE)
        
        _grayOut.path = CGPath(rect: frame, transform: nil)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        refreshLayout()
    }
}
