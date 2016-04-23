//
//  CustomLevelSelectScene.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 4/6/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import SpriteKit

class CustomLevelSelectScene: LevelSelectScene {

    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        _titleLabel.text = "Create or Load Level"
        
        _playLabel.text = "Create"
        
        _textInput.placeholder = "Size or Code"
    }
    
    override func getMaxAllowedLevel() -> Int {
        // Don't allow levels above 256 due to available space in encoding
        return min(Storage.loadLevel(), 256)
    }
    
    override func play() {
        let level = LevelParser.parse(_textInput.text!, allowCustom: true)
        if (level != nil) {
            (UIApplication.sharedApplication().delegate! as! AppDelegate).pushViewController(SKViewController(scene: CreationScene(size: size, level: level!)), animated: true)
        }
    }
}
