//
//  AchievementPopup.swift
//  Astro Maze
//
//  Created by Jonathan Noyola on 8/1/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import SpriteKit

class Popup: SKShapeNode {

    enum State {
        case Open
        case Closed
    }

    var _heightScale: CGFloat = 1
    var _cornerRadius: CGFloat = 0
    var _state: State = .Open
    var _background: SKShapeNode? = nil
    
    var _yOpen: CGFloat = 0
    var _yClose: CGFloat = 0

    init(heightScale: CGFloat, addBackground: Bool, cornerRadius: CGFloat = 10, state: State = .Open) {
        super.init()
        
        _heightScale = heightScale
        _cornerRadius = cornerRadius
        _state = state
        fillColor = UIColor.whiteColor()
        
        if addBackground {
            _background = SKShapeNode()
            _background!.lineWidth = 0
            _background!.fillColor = SKColor.blackColor()
            _background!.alpha = 0.8
            _background!.zPosition = -1
            addChild(_background!)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func open(completion: () -> Void) {
        _state = .Open
        runAction(SKAction.moveToY(_yOpen, duration: 0.2), completion: completion)
    }
    
    func close() {
        _state = .Closed
        _background?.removeFromParent()
        _background = nil
        runAction(SKAction.moveToY(_yClose, duration: 0.2), completion: {
            self.removeFromParent()
        })
    }

    func refreshLayout(size: CGSize) {
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        _yOpen = (h - s * _heightScale) * 0.5
        _yClose = -h * 0.5
        let y = _state == .Open ? _yOpen : _yClose
    
        let rect = CGRect(origin: CGPoint(x: (w - s) * 0.5, y: 0), size: CGSize(width: s, height: s * _heightScale))
        path = CGPathCreateWithRoundedRect(rect, _cornerRadius, _cornerRadius, nil)
        position = CGPoint(x: 0, y: y)
        
        // Background
        if _background != nil {
            let bgRect = CGRect(origin: CGPoint(x: 0, y: -_yOpen), size: CGSize(width: size.width, height: size.height))
            _background!.path = CGPathCreateWithRect(bgRect, nil)
        }
    }
    
}
