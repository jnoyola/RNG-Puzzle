//
//  CoinLabel.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 3/25/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit

class StarLabel: SKNode {

    var _star: Star! = nil
    var _label: SKLabelNode! = nil
    var _starLabel: SKLabelNode? = nil
    
    var _size: CGFloat = 0
    var _anchor: NSTextAlignment = .center

    var _minX: CGFloat = 0
    var _maxX: CGFloat = 0
    var _minY: CGFloat = 0
    var _maxY: CGFloat = 0
    
    init(text: String, color: SKColor, starText: String? = nil, anchor: NSTextAlignment = .center) {
        super.init()
        
        _anchor = anchor
        
        _star = Star(type: .Glowing)
        
        _label = SKLabelNode(fontNamed: Constants.FONT)
        _label.text = text
        _label.fontColor = color
        _label.horizontalAlignmentMode = .center
        
        if starText != nil {
            _starLabel = SKLabelNode(fontNamed: Constants.FONT)
            _starLabel!.text = starText!
            _starLabel!.fontColor = SKColor.black
            _starLabel!.horizontalAlignmentMode = .center
            _starLabel!.zPosition = 1
            addChild(_starLabel!)
        }
        
        addChild(_star)
        addChild(_label)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func disable() {
        _star.fade()
        _label.fontColor = SKColor.darkGray
    }
    
    func animate() {
        let path = Bundle.main.path(forResource: "Sparks", ofType: "sks")
        let particle = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as! SKEmitterNode
        particle.zPosition = 200
            
        self.addChild(particle)
    }
    
    func isPointInBounds(_ p: CGPoint) -> Bool {
        return p.x > position.x + _minX
            && p.x < position.x + _maxX
            && p.y > position.y + _minY - _size / 2
            && p.y < position.y + _maxY + _size / 2
    }
    
    func getText() -> String {
        return _label.text!
    }
    
    func setText(_ text: String) {
        _label.text = text
        refreshLayout()
    }
    
    func setSize(_ size: CGFloat) {
        _size = size
        
        _label.fontSize = _size
        _starLabel?.fontSize = _size * 0.6
        
        _star.setSize(_size * Constants.ICON_TO_TEXT_SCALE)
        
        refreshLayout()
    }
    
    func refreshLayout() {
        let starSize = _size * Constants.ICON_TO_TEXT_SCALE
        let pad = _size * 0.1
        
        switch _anchor {
        case .center:
            _star.position = CGPoint(x: -(pad + _label.frame.size.width) / 2 - _size * 0.2, y: _size * 0.47)
            _label.position = CGPoint(x: (pad + starSize) / 2 - _size * 0.2, y: 0)
            _starLabel?.position = CGPoint(x: _star.position.x, y: _size * 0.15)
        case .left:
            _star.position = CGPoint(x: -pad - starSize / 2, y: _size * 0.47)
            _label.position = CGPoint(x: _label.frame.size.width / 2, y: 0)
            _starLabel?.position = CGPoint(x: _star.position.x, y: _size * 0.15)
        default:
            break
        }
        
        _minX = _star.position.x - _star._size / 2
        _maxX = _label.position.x + _label.frame.size.width / 2
        _minY = -_size * 0.5
        _maxY = starSize
    }
}
