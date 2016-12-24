//
//  AchievementPopup.swift
//  Astro Maze
//
//  Created by Jonathan Noyola on 7/21/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import SpriteKit

class AchievementPopup: Popup {

    var _icon: SKSpriteNode? = nil
    var _description: String! = nil
    var _nameLabel: SKLabelNode! = nil
    var _descLabel: SKMultilineLabel? = nil

    init(name: String, description: String, image: String, addBackground: Bool, state: Popup.State) {
        super.init(heightScale: 0.5, addBackground: addBackground, state: state)
        
        _description = description
        
        _icon = SKSpriteNode(imageNamed: image)
        if _icon != nil {
            addChild(_icon!)
        }
        
        _nameLabel = addLabel(name, color: SKColor.blackColor())
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addLabel(text: String, color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: Constants.FONT)
        label.text = text
        label.fontColor = color
        self.addChild(label)
        return label
    }

    override func refreshLayout(size: CGSize) {
        super.refreshLayout(size)
    
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        // Image
        _icon?.size = CGSize(width: s * 0.3, height: s * 0.3)
        _icon?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        _icon?.position = CGPoint(x: w * 0.5, y: s * 0.5)
        
        // Name
        _nameLabel.position = CGPoint(x: w * 0.5, y: s * 0.25)
        _nameLabel.fontSize = s * Constants.TEXT_SCALE
        
        // Description
        _descLabel?.removeFromParent()
        _descLabel = SKMultilineLabel(text: _description, labelWidth: s * 0.9, pos: CGPoint(x: w * 0.5, y: s * (0.24 - Constants.TEXT_SCALE * 1.5)), fontName: Constants.FONT, fontSize: s * Constants.TEXT_SCALE * 0.75, fontColor: UIColor.darkGrayColor(), spacing: 1.5, alignment: .Center, shouldShowBorder: false)
        addChild(_descLabel!)
    }
    
}
