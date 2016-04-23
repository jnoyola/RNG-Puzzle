//
//  LevelSelectScene.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 9/24/15.
//  Copyright © 2015 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit

class LevelSelectScene: SKScene, UITextFieldDelegate {

    var _titleLabel: SKLabelNode! = nil
    var _backLabel: SKLabelNode! = nil
    var _playLabel: SKLabelNode! = nil
    var _textInput: UITextField! = nil

    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        // Title
        _titleLabel = addLabel("Select Level", color: SKColor.blueColor())
        
        // Back
        _backLabel = addLabel("Back", color: SKColor.whiteColor())
        
        // Play
        _playLabel = addLabel("Play", color: SKColor.whiteColor())
        
        // Text Input
        _textInput = UITextField.init()
        _textInput.backgroundColor = UIColor.whiteColor()
        _textInput.textAlignment = .Center
        _textInput.keyboardType = .DecimalPad
        _textInput.autocorrectionType = .No
        _textInput.placeholder = "Level"
        _textInput.text = String(Storage.loadLevel())
        _textInput.delegate = self;
        _textInput.becomeFirstResponder()
        view.addSubview(self._textInput)
    
        refreshLayout()
    }
    
    override func willMoveFromView(view: SKView) {
        _textInput.removeFromSuperview()
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
        let w = size.width
        let h = size.height
        if (p.y > h * 0.56 && p.y < h * 0.76) {
            if (p.x < w * 0.25) {
                back()
            } else if (p.x > w * 0.75) {
                play()
            }
        }
    }
    
    func back() {
        (UIApplication.sharedApplication().delegate!.window!!.rootViewController! as! UINavigationController).popViewControllerAnimated(true)
    }
    
    func play() {
        let level = LevelParser.parse(_textInput.text!, allowGenerated: true, allowCustom: true)
        if (level != nil) {
            presentScene(LevelGenerationScene(size: size, level: level!))
        }
    }
    
    func presentScene(scene: SKScene) {
        (UIApplication.sharedApplication().delegate! as! AppDelegate).pushViewController(SKViewController(scene: scene), animated: true)
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
            return false
        }
        return true
    }
    
    func getMaxAllowedLevel() -> Int {
        return Storage.loadLevel()
    }
    
    func refreshLayout() {
        if _titleLabel == nil {
            return
        }
    
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        _titleLabel.fontSize = s * 0.08
        _titleLabel.position = CGPoint(x: w * 0.5, y: h * 0.85)
        
        _backLabel.fontSize = s * 0.064
        _backLabel.position = CGPoint(x: w * 0.15, y: h * 0.663)
        
        _playLabel.fontSize = s * 0.064
        _playLabel.position = CGPoint(x: w * 0.85, y: h * 0.663)
        
        let inputWidth: CGFloat = 200.0/480.0 * w
        let inputHeight: CGFloat = s * 0.09
        let inputX = 0.5 * w - inputWidth / 2
        let inputY = 0.31 * h - inputHeight / 2
        _textInput.frame = CGRect(x: inputX, y: inputY, width: inputWidth, height: inputHeight)
        _textInput.font = UIFont(name: "Optima-ExtraBlack", size: s * 0.06)
    }
    
    override func didChangeSize(oldSize: CGSize) {
        refreshLayout()
    }
}
