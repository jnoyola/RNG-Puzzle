//
//  PlanetCompleteScene.swift
//  Astro Maze
//
//  Created by Jonathan Noyola on 8/1/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import SpriteKit

class PlanetCompleteScene: SKScene {

    var _baseLevel = 0
    var _titleLabel: SKLabelNode! = nil
    var _questionLabel: SKLabelNode! = nil
    var _viewAdLabel: SKLabelNode! = nil
    var _sacrificeLabel: StarLabel! = nil
    
    var _planet: PlanetDisplay! = nil
    var _scale: CGFloat = 0

    init(size: CGSize, levelNum: Int) {
        super.init(size: size)
        
        _baseLevel = (levelNum - 1) / 10
        _scale = 0.2 + CGFloat(_baseLevel % 7) * 0.03
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        _titleLabel = addLabel("Planet Complete!", color: Constants.TITLE_COLOR)
        _questionLabel = addLabel("Cosmic travel method?", color: SKColor.white)
        _viewAdLabel = addLabel("View ad", color: SKColor.white)
        _sacrificeLabel = StarLabel(text: "Sacrifice", color: SKColor.white, starText: "10", anchor: .left)
        addChild(_sacrificeLabel)
        
        _planet = PlanetDisplay(baseLevel: _baseLevel, showStars: false, showLevels: false, showTaunt: false)
        addChild(_planet)
        
        refreshLayout()
    }
    
    func addLabel(_ text: String, color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: Constants.FONT)
        label.text = text
        label.fontColor = color
        self.addChild(label)
        return label
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
        
        let y = s * (Constants.ICON_SCALE - Constants.TEXT_SCALE)
        
        _questionLabel.fontSize = s * Constants.TEXT_SCALE
        _questionLabel.position = CGPoint(x: w * 0.5, y: y + s * Constants.TEXT_SCALE * 2)
        
        _viewAdLabel.fontSize = s * Constants.TEXT_SCALE
        _viewAdLabel.position = CGPoint(x: w - _viewAdLabel.frame.width * 0.5 - s * Constants.TEXT_SCALE * 0.5, y: y)
        
        _sacrificeLabel.setSize(s * Constants.TEXT_SCALE)
        _sacrificeLabel.position = CGPoint(x: s * Constants.ICON_SCALE * 1.2, y: y)
        
        _planet.position = CGPoint(x: w * 0.5, y: h * 0.5)
        _planet.refreshLayout(size: size)
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        refreshLayout()
    }
}
