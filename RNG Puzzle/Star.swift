//
//  Star.swift
//  Astro Maze
//
//  Created by Jonathan Noyola on 7/25/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import SpriteKit

class Star: SKNode {

    enum StarType {
        case Glowing
        case Filled
        case Empty
    }

    var _scene: SKScene? = nil
    var _size: CGFloat = 1
    var _star: SKSpriteNode! = nil
    
    let _explosionScale: CGFloat = 0.25

    init(type: StarType, scene: SKScene? = nil) {
        super.init()
        
        _scene = scene
        
        switch type {
        case .Glowing: _star = SKSpriteNode(imageNamed: "star")
        case .Filled: _star = SKSpriteNode(imageNamed: "star_emblem")
        case .Empty: _star = SKSpriteNode(imageNamed: "star_missing_emblem")
        }
        _star.position = CGPoint.zero
        addChild(_star)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setSize(_ size: CGFloat) {
        _size = size
        _star.size = CGSize(width: _size, height: _size)
    }
    
    func explodeTo(dest: CGPoint, isEmblemFilled: Bool = true, completion: (() -> Void)? = nil) {
    
        if isEmblemFilled {
            _star.texture = SKTexture(imageNamed: "star_emblem")
        } else {
            _star.texture = SKTexture(imageNamed: "star_missing_emblem")
        }
    
        for i in 0...4 {
            let angle = CGFloat(i) * 2 * CGFloat(M_PI) / 5
        
            let shard = SKSpriteNode(imageNamed: "shard")
            shard.size = CGSize(width: _size, height: _size)
            shard.zPosition = 10000
            shard.zRotation = angle
            if _scene != nil {
                shard.position = _scene!.convert(self.position, from: self.parent!)
                _scene!.addChild(shard)
            } else {
                shard.position = CGPoint.zero
                addChild(shard)
            }
            
            // Note that angle 0 points up
            let dx = -sin(angle) * _size * _explosionScale
            let dy = cos(angle) * _size * _explosionScale
            let actionExplode = SKAction.moveBy(x: dx, y: dy, duration: 0.04)
            
            let actionWait = SKAction.wait(forDuration: 0.25)
            
            let duration = 0.5 + Double(arc4random_uniform(5)) * 0.05
        
            let newAngle = atan2(dest.y - shard.position.y, dest.x - shard.position.x) + CGFloat(M_PI) / 2
            let actionRotate = SKAction.rotate(toAngle: newAngle, duration: duration, shortestUnitArc: true)
            actionRotate.timingMode = .easeIn
            
            let actionTarget = SKAction.move(to: dest, duration: duration)
            actionTarget.timingMode = .easeIn
            
            shard.run(SKAction.sequence([actionExplode, actionWait, SKAction.group([actionRotate, actionTarget])]), completion: {
                shard.removeFromParent()
                if i == 0 {
                    completion?()
                }
            })
        }
    }
    
    func fade() {
        _star.color = SKColor.black
        _star.colorBlendFactor = 0.5
    }
}
