//
//  GameView.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 10/8/15.
//  Copyright © 2015 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit

class GameView: SKNode {
    
    var _origX: CGFloat = 0.0
    var _origY: CGFloat = 0.0
    var _baseScale: CGFloat = 1.0
    var _scale: CGFloat = 1.0

    var _level: Level! = nil
    var _ball: SKSpriteNode! = nil
    var _ballX = 0
    var _ballY = 0
    var _dir = Direction.Still

    init(level: Level, x: CGFloat, y: CGFloat, scale: CGFloat) {
        super.init()
        _level = level
        setBaseScale(scale)
        _origX = x - getWidth() / 2
        _origY = y - getHeight() / 2
        position = CGPoint(x: _origX, y: _origY)
        
        _ball = SKSpriteNode(texture: Sprites().ball())
        _ball.size = CGSize(width: 1, height: 1)
        _ball.zPosition = 5
        addChild(_ball)
        
        drawLevel(level)
        
        resetBall()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func drawLevel(level: Level) {
        let sprites = Sprites()
    
        for i in 0...(level._width-1) {
            for j in 0...(level._height-1) {
                let piece = level.getPiece(x: i, y: j)
                var node: SKSpriteNode! = nil
                var z: CGFloat = 10
                if piece.contains(.Block) {
                    node = SKSpriteNode(texture: sprites.block())
                } else if piece.contains(.Corner1) {
                    node = SKSpriteNode(texture: sprites.corner1())
                } else if piece.contains(.Corner2) {
                    node = SKSpriteNode(texture: sprites.corner2())
                } else if piece.contains(.Corner3) {
                    node = SKSpriteNode(texture: sprites.corner3())
                } else if piece.contains(.Corner4) {
                    node = SKSpriteNode(texture: sprites.corner4())
                } else if piece.contains(.Teleporter) {
                    node = SKSpriteNode(texture: sprites.teleport())
                    node.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(M_PI), duration: 0.5)))
                    z = 1
                } else if piece.contains(.Target) {
                    node = SKSpriteNode(texture: sprites.target())
                    node.runAction(SKAction.repeatActionForever(SKAction.rotateByAngle(CGFloat(M_PI), duration: 0.5)))
                    z = 1
                } else {
                    continue
                }
                node.size = CGSize(width: 1, height: 1)
                node.position = CGPoint(x: CGFloat(i) + 0.5, y: CGFloat(j) + 0.5)
                node.zPosition = z
                self.addChild(node)
            }
        }
        
        // Draw background
        let bg = SKSpriteNode(color: UIColor.blackColor(), size: CGSize(width: level._width, height: level._height))
        bg.position = CGPoint(x: CGFloat(level._width) / 2, y: CGFloat(level._height) / 2)
        bg.zPosition = -1
        self.addChild(bg)
    }
    
    func setBaseScale(scale: CGFloat) {
        _baseScale = scale
        _scale = 1.0
        super.setScale(scale)
    }
    
    func scale(scale: CGFloat) {
        setScale(_scale * scale)
    }
        
    override func setScale(scale: CGFloat) {
        _scale = scale
        
        // Min scale means the level fills 75% of the screen
        // Max scale means 5 spaces fit in the screen
        if _scale < 0.75 {
            _scale = 0.75
        } else if _scale > CGFloat(_level._height) / 5 {
            _scale = CGFloat(_level._height) / 5
        }
        
        super.setScale(_scale * _baseScale)
    }
    
    func getWidth() -> CGFloat {
        return CGFloat(_level._width) * _baseScale * _scale
    }
    
    func getHeight() -> CGFloat {
        return CGFloat(_level._height) * _baseScale * _scale
    }
    
    // -----------------------------------------------------------------------
    
    func resetBall() {
        _ballX = _level._startX
        _ballY = _level._startY
        _ball.position = CGPoint(x: CGFloat(_ballX) + 0.5, y: CGFloat(_ballY) + 0.5)
        
        let startScale = _scale
        let duration: Double = 0.2
        print(_origX, _origY)
        runAction(SKAction.moveTo(CGPoint(x: _origX, y: _origY), duration: duration))
        runAction(SKAction.customActionWithDuration(duration, actionBlock: { (node: SKNode, elapsedTime: CGFloat) -> Void in
            let scale = elapsedTime / CGFloat(duration) * (1 - startScale) + startScale
            self.setScale(scale)
        }))
    }
}
