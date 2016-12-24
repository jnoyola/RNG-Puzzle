//
//  LevelSelectViewController.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 7/3/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

class LevelSelectViewController: SKViewController {

    var _levelSelectScene: LevelSelectScene! = nil

    init(levelSelectScene: LevelSelectScene) {
        super.init(scene: levelSelectScene)
        _levelSelectScene = levelSelectScene
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillLayoutSubviews() {
//        _levelSelectScene._textInput!.becomeFirstResponder()
    }
}
