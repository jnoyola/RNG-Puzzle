//
//  Blob.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 5/31/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import SpriteKit

class Blob: SKSpriteNode {

    let sprites = BlobSprites()
    
    var _animated = true
    
    var _idleTimer: Timer? = nil
    
    var _idleAnimations: [() -> Void]! = nil
    var _stopAnimations: [(_ dir: Direction, _ dtheta: CGFloat, _ dt: Double) -> Void]! = nil
    
    var resetAngle: CGFloat = 0
    var resetPos: CGPoint? = nil

    init(animated: Bool = true) {
        super.init(texture: sprites.root_root(), color: UIColor.white, size: CGSize(width: 1, height: 1))
        
        _animated = animated
        
        if _animated {
            _idleAnimations = [animIdleBlink, animIdleSpit]
            _stopAnimations = [animStopSpin, animStopSplat]
        
            startIdleTimer()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func reset(hard: Bool = false) {
        removeAllActions()
        
        if hard {
            resetPos = nil
            run(SKAction.setTexture(sprites.root_root()))
        } else {
            if resetPos != nil {
                run(SKAction.sequence([
                    SKAction.setTexture(sprites.root_root()),
                    SKAction.rotate(toAngle: resetAngle, duration: 0),
                    SKAction.move(to: resetPos!, duration: 0)
                ]))
                resetPos = nil
            }
        }
    }
    
    func startIdleTimer() {
        _idleTimer?.invalidate()
        _idleTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(idle), userInfo: nil, repeats: false)
    }
    
    func stopIdleTimer() {
        _idleTimer?.invalidate()
        _idleTimer = nil
    }
    
    func idle() {
        let idx = Int(arc4random_uniform(UInt32(_idleAnimations.count)))
        
        _idleAnimations[idx]()
        
        if _animated {
            startIdleTimer()
        }
    }
    
    func stop(dir: Direction, dtheta: CGFloat, dt: Double) {
        let idx = Int(arc4random_uniform(UInt32(_stopAnimations.count)))
        
        _stopAnimations[idx](dir, dtheta, dt)
        
        if _animated {
            startIdleTimer()
        }
    }
    
    func animIdleBlink() {
        let anim = SKAction.animate(with: [
            sprites.root_blink(),
            sprites.root_root(),
            sprites.root_blink(),
            sprites.root_root()
        ], timePerFrame: 0.08)
        run(anim)
    }
    
    func animIdleSpit() {
        let anim = SKAction.animate(with: sprites.spit_spit_(), timePerFrame: 0.08)
        run(anim)
    }
    
    func animStopSpin(dir: Direction, dtheta: CGFloat, dt: Double) {
        
        resetAngle = zRotation
        resetPos = position
    
        var textures = sprites.spin_eyes_spin_eyes_()
        
        if dtheta > 0 {
            textures = textures.reversed()
        }
        textures.append(sprites.root_root())
        
        let anim = SKAction.animate(with: textures, timePerFrame: 0.015)
        run(anim)
        
        let margin: CGFloat = 0.22
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        switch dir {
        case .Right: x = 1
        case .Up:    y = 1
        case .Left:  x = -1
        case .Down:  y = -1
        default: break
        }
        x *= margin
        y *= margin
        let angle = dtheta * margin * 2
        let duration = dt * Double(margin) * 2
        
        run(SKAction.sequence([
            SKAction.rotate(byAngle: angle, duration: duration),
            SKAction.rotate(byAngle: -angle, duration: duration * 4)
        ]))
        
        run(SKAction.sequence([
            SKAction.moveBy(x: x, y: y, duration: duration),
            SKAction.moveBy(x: -x, y: -y, duration: duration * 4)
        ]))
    }
    
    func animStopSplat(dir: Direction, dtheta: CGFloat, dt: Double) {
    
        resetAngle = zRotation
        resetPos = position
        
        let margin: CGFloat = 0.22
    
        var x: CGFloat = 0
        var y: CGFloat = 0
        switch dir {
        case .Right: x = 1
                     zRotation = 0
        case .Up:    y = 1
                     zRotation = CGFloat(0.5 * M_PI)
        case .Left:  x = -1
                     zRotation = CGFloat(M_PI)
        case .Down:  y = -1
                     zRotation = CGFloat(1.5 * M_PI)
        default: break
        }
        x *= margin
        y *= margin
        let angle = dtheta * margin * 2
        let duration = dt * Double(margin) * 2
        
        zRotation -= angle
        
        run(SKAction.rotate(byAngle: angle, duration: duration))
        
        run(SKAction.sequence([
            SKAction.moveBy(x: x, y: y, duration: duration),
            SKAction.animate(with: sprites.splat_splat_(), timePerFrame: 0.015),
            SKAction.setTexture(sprites.root_root()),
            SKAction.rotate(toAngle: resetAngle, duration: 0),
            SKAction.moveBy(x: -x, y: -y, duration: 0)
        ]))
    }
}
