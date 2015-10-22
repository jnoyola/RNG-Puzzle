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
    
    var _playScene: PlayScene! = nil
    var _origX: CGFloat = 0.0
    var _origY: CGFloat = 0.0
    var _baseScale: CGFloat = 1.0
    var _scale: CGFloat = 1.0

    var _level: Level! = nil
    var _ball: SKSpriteNode! = nil
    var _ballX = 0
    var _ballY = 0
    var _dir = Direction.Still
    var _spin: CGFloat = 0.0
    var _nextPiece: PieceType! = nil
    
    let _ballSpeed = 0.1
    let _ballSpinSpeed: CGFloat = 2.0
    
    let _winDuration = 0.5

    init(level: Level, playScene: PlayScene) {
        super.init()
        _level = level
        _playScene = playScene
        
        // Scale 1.0 means the level fits in the scene
        let scale = min(_playScene.size.width / CGFloat(level._width), _playScene.size.height / CGFloat(level._height))
        setBaseScale(scale)
        _origX = (_playScene.size.width - getWidth()) / 2
        _origY = (_playScene.size.height - getHeight()) / 2
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
        runAction(SKAction.moveTo(CGPoint(x: _origX, y: _origY), duration: duration))
        runAction(SKAction.customActionWithDuration(duration, actionBlock:
            { (node: SKNode, elapsedTime: CGFloat) -> Void in
                let scale = elapsedTime / CGFloat(duration) * (1 - startScale) + startScale
                self.setScale(scale)
            }
        ))
    }
    
    func attemptMove(dir: Direction, swipe: CGPoint) {
        // Can't redirect ball while moving
        if _dir != .Still {
            return
        }
        
        // Can't move through walls
        if cannotMove(dir) {
            // stop()
            return
        }
        
        // Now that we know this is a valid move...
        _spin = -1
        let ballX = position.x + _ball.position.x * _scale * _baseScale
        let ballY = _playScene.size.height - (position.y + _ball.position.y * _scale * _baseScale)
        switch dir {
        case .Right:
            if swipe.y > ballY {
                _spin = 1
            }
        case .Up:
            if swipe.x > ballX {
                _spin = 1
            }
        case .Left:
            if swipe.y < ballY {
                _spin = 1
            }
        case .Down:
            if swipe.x < ballX {
                _spin = 1
            }
        default: break
        }
        move(dir)
    }
    
    func move(dir: Direction) {
        _dir = dir
        var x = 0
        var y = 0
        switch dir {
        case .Right: x = 1
        case .Up:    y = 1
        case .Left:  x = -1
        case .Down:  y = -1
        default: break
        }
        _ballX += x
        _ballY += y
        _ball.runAction(SKAction.rotateByAngle(_spin * _ballSpinSpeed, duration: _ballSpeed))
        _ball.runAction(SKAction.moveByX(CGFloat(x), y: CGFloat(y), duration: _ballSpeed), completion: doneMoving)
    }
    
    func doneMoving() {
        if _nextPiece.contains(.Target) {
            win()
            return
        } else if _nextPiece.contains(.Void) {
            stop()
            resetBall()
            return
        } else if _nextPiece.contains(.Teleporter) {
            teleport()
            if cannotMove(_dir) {
                stop()
            } else {
                move(_dir)
                updateNextPiece(x: _ballX, y: _ballY)
            }
            return
        } else if _nextPiece.contains(.Corner1) {
            if _dir == .Left {
                _spin = 1
                move(.Up)
            } else if _dir == .Down {
                _spin = -1
                move(.Right)
            }
            updateNextPiece(x: _ballX, y: _ballY)
            return
        } else if _nextPiece.contains(.Corner2) {
            if _dir == .Down {
                _spin = 1
                move(.Left)
            } else if _dir == .Right {
                _spin = -1
                move(.Up)
            }
            updateNextPiece(x: _ballX, y: _ballY)
            return
        } else if _nextPiece.contains(.Corner3) {
            if _dir == .Right {
                _spin = 1
                move(.Down)
            } else if _dir == .Up {
                _spin = -1
                move(.Left)
            }
            updateNextPiece(x: _ballX, y: _ballY)
            return
        } else if _nextPiece.contains(.Corner4) {
            if _dir == .Up {
                _spin = 1
                move(.Right)
            } else if _dir == .Left {
                _spin = -1
                move(.Down)
            }
            updateNextPiece(x: _ballX, y: _ballY)
            return
        }
        
        if cannotMove(_dir) {
            stop()
            return
        }
        
        move(_dir)
    }
    
    func cannotMove(dir: Direction) -> Bool {
        let piece = updateNextPiece(dir)
        if (piece == .Block) ||
           (piece == .Corner1 && (dir == .Right || dir == .Up))   ||
           (piece == .Corner2 && (dir == .Up    || dir == .Left)) ||
           (piece == .Corner3 && (dir == .Left  || dir == .Down)) ||
           (piece == .Corner4 && (dir == .Down  || dir == .Right)) {
            return true
        }
        return false
    }
    
    func updateNextPiece(x x: Int, y: Int) -> PieceType {
        if x >= 0 && y >= 0 && x < _level._width && y < _level._height {
            _nextPiece = _level.getPiece(x: x, y: y)
        } else {
            _nextPiece = .Void
        }
        return _nextPiece
    }
    
    func updateNextPiece(dir: Direction) -> PieceType {
        var x = _ballX
        var y = _ballY
        switch dir {
        case .Right: ++x
        case .Up:    ++y
        case .Left:  --x
        case .Down:  --y
        default: break
        }
        return updateNextPiece(x: x, y: y)
    }
    
    func teleport() {
        let dst = _level.getTeleporterPair(x: _ballX, y: _ballY)
        _ballX = dst.x
        _ballY = dst.y
        _ball.position = CGPoint(x: CGFloat(_ballX) + 0.5, y: CGFloat(_ballY) + 0.5)
    }
    
    func stop() {
        _ball.removeAllActions()
        _dir = .Still
    }
    
    func win() {
        _ball.runAction(SKAction.rotateByAngle(_spin * _ballSpinSpeed, duration: _winDuration))
        _ball.runAction(SKAction.scaleTo(0.01, duration: _winDuration), completion: { () -> Void in
            self._playScene.complete()
        })
    }
}
