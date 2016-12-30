//
//  GameSample.swift
//  Astro Maze
//
//  Created by Jonathan Noyola on 7/29/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import SpriteKit

class GameSample: SKNode {

    var _gameView: GameView! = nil

    init(levelNum: Int, parentScene: SKScene, cornerRadius: CGFloat = 10) {
        super.init()
        
        let level = Level(level: levelNum, seed: nil)
        let _ = level.generate(debug: false)
        _gameView = GameView(level: level, parent: parentScene, winCallback: {})
        _gameView.setScale(0.5)
        _gameView.position = CGPoint(x: -_gameView.getWidth() / 2, y: -_gameView.getHeight() / 2)
        _gameView.zPosition = 100
        addChild(_gameView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
