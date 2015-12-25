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
    
        let sprites = Sprites()
        let width = parent.frame.height * 0.15
        let size = CGSize(width: width, height: width)
        _finger = SKSpriteNode(texture: sprites.finger(), size: size)
        _shadow = SKSpriteNode(texture: sprites.finger_shadow(), size: size)
        
        _finger.zPosition = 11
        _shadow.zPosition = 10
        setPosition(x: x, y: y, z: z)
        
        parent.addChild(_finger)
        parent.addChild(_shadow)
    }
    
    func setPosition(x x:CGFloat, y: CGFloat, z: CGFloat) {
        _x = x
        _y = y
        _z = z
        _shadow.position = CGPoint(x: x, y: y)
        _finger.position = CGPoint(x: x, y: y + z)
    }

    func animateTo(x x: CGFloat, y: CGFloat, z: CGFloat, duration: Double, callback: () -> Void) {
        // Update prematurely -- don't use these for anything important
        _x = x
        _y = y
        _z = z
        
        let fingerPoint = CGPoint(x: x, y: y + z)
        let shadowPoint = CGPoint(x: x, y: y)
        
        _finger.runAction(SKAction.moveTo(fingerPoint, duration: duration), completion: callback)
        _shadow.runAction(SKAction.moveTo(shadowPoint, duration: duration))
    }
    
    func remove() {
        _finger.removeFromParent()
        _shadow.removeFromParent()
    }
}
