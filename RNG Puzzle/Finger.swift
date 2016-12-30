//
//  Finger.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 10/22/15.
//  Copyright © 2015 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit

class Finger: NSObject {

    var _finger: SKSpriteNode! = nil
    var _shadow: SKSpriteNode! = nil
    
    var _x: CGFloat = 0
    var _y: CGFloat = 0
    var _z: CGFloat = 0

    init(x: CGFloat, y: CGFloat, z: CGFloat, parent: SKNode) {
        super.init()
    
        let sprites = PieceSprites()
        _finger = SKSpriteNode(texture: sprites.finger())
        _shadow = SKSpriteNode(texture: sprites.finger_shadow())
        resetSize(parent: parent)
        
        _finger.zPosition = 11
        _shadow.zPosition = 10
        setPosition(x: x, y: y, z: z)
        
        parent.addChild(_finger)
        parent.addChild(_shadow)
    }
    
    func setPosition(x: CGFloat, y: CGFloat, z: CGFloat) {
        _x = x
        _y = y
        _z = z
        _shadow.position = CGPoint(x: x, y: y)
        _finger.position = CGPoint(x: x, y: y + z)
    }
    
    func resetSize(parent: SKNode) {
        let s = min(parent.frame.width, parent.frame.height)
        let size = CGSize(width: s * 0.2, height: s * 0.2)
        _finger.size = size
        _shadow.size = size
    }

    func animateTo(x: CGFloat, y: CGFloat, z: CGFloat, duration: Double, callback: @escaping () -> Void) {
        // Update prematurely -- don't use these for anything important
        _x = x
        _y = y
        _z = z
        
        let fingerPoint = CGPoint(x: x, y: y + z)
        let shadowPoint = CGPoint(x: x, y: y)
        
        let fingerAction = SKAction.sequence([
            SKAction.move(to: fingerPoint, duration: duration),
            SKAction.run({ callback() })
        ])
        let shadowAction = SKAction.move(to: shadowPoint, duration: duration)
        
        _finger.run(fingerAction, withKey: "action")
        _shadow.run(shadowAction, withKey: "action")
    }
    
    func remove() {
        _finger.removeFromParent()
        _shadow.removeFromParent()
        _finger.removeAction(forKey: "action")
        _shadow.removeAction(forKey: "action")
    }
}
