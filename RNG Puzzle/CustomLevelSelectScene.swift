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
        
        _titleLabel.text = "Create or Load"
        
        _playLabel.text = "Create"
        
        _textInput!.placeholder = "Size or Code"
    }
    
    override func createPlanetarium(maxLevel: Int) {
        _planetarium = Planetarium(showStars: false, showTaunt: false)
        addChild(_planetarium!)
    }
    
    override func createStarLabel() {}
    
    override func getMaxAllowedLevel() -> Int {
        // Don't allow levels above 753 due to available space in encoding (level 753 has a width of 255)
        return min(Storage.loadMaxLevel(), 750)
    }
    
    override func play() {
        let level = LevelParser.parse(_textInput!.text!, allowCustom: true)
        if (level != nil) {
            AppDelegate.pushViewController(SKViewController(scene: CreationScene(size: size, level: level!)), animated: true, offset: 0)
        }
    }
}
