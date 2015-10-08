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

    var _textInput: UITextField! = nil

    override func didMoveToView(view: SKView) {
        backgroundColor = SKColor.blackColor()
        
        let height = size.height
        let width = size.width
        
        // Title
        addLabel("Select Level", size: height * 0.08, color: SKColor.blueColor(), x: 0.5, y: 0.85)
        
        // Back
        addLabel("Back", size: height * 0.064, color: SKColor.whiteColor(), x: 0.15, y: 0.663)
        
        // Play
        addLabel("Play", size: height * 0.064, color: SKColor.whiteColor(), x: 0.85, y: 0.663)
        
        // Text Input
        let input_width: CGFloat = 200.0/480.0 * size.width
        let input_height: CGFloat = height * 0.09
        let input_x = 0.5 * width - input_width / 2
        let input_y = 0.31 * height - input_height / 2
        _textInput = UITextField.init(frame: CGRectMake(input_x, input_y, input_width, input_height))
        _textInput.backgroundColor = UIColor.whiteColor()
        _textInput.textAlignment = .Center
        _textInput.font = UIFont(name: "Optima-ExtraBlack", size: height * 0.06)
        _textInput.keyboardType = .DecimalPad
        _textInput.autocorrectionType = .No
        /*_textInput.placeholder = @"Level";
        _textInput.text = [NSString stringWithFormat:@"%i", [self loadLevel]];*/
        _textInput.delegate = self;
        _textInput.becomeFirstResponder()
        view.addSubview(_textInput);
    }
    
    func addLabel(text: String, size: CGFloat, color: SKColor, x: CGFloat, y: CGFloat) {
        let label = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        label.text = text
        label.fontSize = size
        label.fontColor = color
        label.position = CGPointMake(self.size.width*x, self.size.height*y)
        self.addChild(label)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        let p = touch.locationInNode(self)
        if (p.x < size.width * 0.25) {
            removeTextInput()
            let introScene = IntroScene(size: size)
            introScene.scaleMode = scaleMode
            view?.presentScene(introScene)
        } else if (p.x > size.width * 0.75) {
            let level = parseInputLevel()
            removeTextInput()
            let levelGenerationScene = LevelGenerationScene(size: size, level: level)
            levelGenerationScene.scaleMode = scaleMode
            view?.presentScene(levelGenerationScene)
        }
    }
    
    func removeTextInput() {
        _textInput.removeFromSuperview()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        for c in string.characters {
            if (c < "0" || c > "9") && c != "." {
                return false
            }
        }
        return true
    }
    
    func parseInputLevel() -> Level {
        let level = Level()
        let tokens = _textInput.text?.componentsSeparatedByString(".")

        // Parse level
        let levelNum = (tokens![0] as NSString).integerValue
        if levelNum > 0 {
            level._level = levelNum
        }
        
        if tokens!.count > 1 && !tokens![1].isEmpty {
            // Parse seed
            let seed = (tokens![1] as NSString).integerValue
            if seed >= 0 {
                level._seed = UInt32(seed)
            }
        }
        
        return level;
    }
}
