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
    
    var _parent: SKScene! = nil
    var _winCallback: (() -> Void)? = nil
    var _origX: CGFloat = 0.0
    var _origY: CGFloat = 0.0
    var _baseScale: CGFloat = 1.0
    var _origScale: CGFloat = 1.0
    var _scale: CGFloat = 1.0

    var _level: LevelProtocol! = nil
    var _ball = Blob()
    var _ballX = 0
    var _ballY = 0
    var _dir = Direction.Still
    var _spin: CGFloat = 0.0
    var _nextPiece: PieceType! = nil
    
    let _ballSpeed = 0.15
    let _ballSpinSpeed: CGFloat = 3.0
    
    let _winDuration = 0.5
    
    var _hintPath: SKShapeNode? = nil
    var _correctIdx = 0
    
    var _didEnterVoid = false

    init(level: LevelProtocol, parent: SKScene, winCallback: (() -> Void)?) {
        super.init()

        _level = level
        _parent = parent
        _winCallback = winCallback
        
        resetBaseScale()
        
        _ball.zPosition = 5
        if level._startX >= 0 {
            addChild(_ball)
        }
        
        drawLevel(_level)
        
        resetBall(instantly: true)
        
        _origScale = _scale
        changeSize()
        position = CGPoint(x: _origX, y: _origY)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func drawLevel(level: LevelProtocol) {
    
        // Draw Pieces
        drawPieces(level)
        
        // Draw Path
        //drawPath(1000)
        
        // Draw background
        let color = Constants.colorForLevel(level._level)
        let bg = SKSpriteNode(color: color, size: CGSize(width: level._width, height: level._height))
        bg.position = CGPoint(x: CGFloat(level._width) / 2, y: CGFloat(level._height) / 2)
        bg.zPosition = -1
        self.addChild(bg)
    }
    
    func drawPieces(level: LevelProtocol) {
        let sprites = PieceSprites()
        
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
                    node = SKSpriteNode(texture: sprites.teleporter())
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
    }
    
    func drawPath(num: Int) {
        if _level._correct == nil {
            return
        }
    
        if _hintPath != nil {
            _hintPath!.removeFromParent()
        }
    
        var x = _level._startX
        var y = _level._startY
        let path = CGPathCreateMutable()
        //var usedTeleporters = Set<PointRecord>()
        CGPathMoveToPoint(path, nil, CGFloat(x) + 0.5, CGFloat(y) + 0.5)
        
        var i = 0
        var correct = _level._correct![i]
        var piece = _level.getPieceSafely((x: x, y: y))
        while i < num {
        
            // Draw path
            CGPathAddLineToPoint(path, nil, CGFloat(x) + 0.5, CGFloat(y) + 0.5)
            
            if x == correct.x && y == correct.y {
                i += 1
                if i == _level._correct!.count {
                    break
                }
                correct = _level._correct![i]
            }
            
            if piece.contains(.Teleporter) {
                let dst = _level.getTeleporterPair(x: x, y: y)
                x = dst.x
                y = dst.y
                CGPathMoveToPoint(path, nil, CGFloat(x) + 0.5, CGFloat(y) + 0.5)
            } 
            piece = getNextPiece(x: x, y: y, dir: correct.dir)
            
            switch correct.dir {
            case .Right: x += 1
            case .Up:    y += 1
            case .Left:  x -= 1
            case .Down:  y -= 1
            default: break
            }
        }
        _hintPath = SKShapeNode(path: path)
        _hintPath!.strokeColor = UIColor.yellowColor()
        _hintPath!.lineWidth = 0.25
        _hintPath!.antialiased = false
        _hintPath!.zPosition = 0
        self.addChild(_hintPath!)
    }
    
    func resetBaseScale() {
        // Scale 1.0 means the level fits in the scene
        var m0: CGFloat = 0
        var m1: CGFloat = 0
        if let playScene = _parent as? PlayScene {
            m0 = playScene._marginRight
            m1 = playScene._marginBottom
        }
        let scale = min((_parent.size.width - m0) / CGFloat(_level._width), (_parent.size.height - m1) / CGFloat(_level._height))
        setBaseScale(scale)
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
        
        if !(_parent is InstructionsScene) && !(_parent is LevelSelectScene) {
            // Min scale means the level fills 75% of the screen
            // Max scale means 5 spaces fit in the screen
            if _scale <= 0.75 {
                _scale = 0.75
            } else {
                let upperLimit = max(1.0, CGFloat(max(_level._width, _level._height)) / 5)
                if _scale > upperLimit {
                    _scale = upperLimit
                }
            }
        }
        
        super.setScale(_scale * _baseScale)
    }
    
    func getWidth() -> CGFloat {
        return CGFloat(_level._width) * _baseScale * _scale
    }
    
    func getHeight() -> CGFloat {
        return CGFloat(_level._height) * _baseScale * _scale
    }
    
    func getOrigWidth() -> CGFloat {
        return CGFloat(_level._width) * _baseScale * _origScale
    }
    
    func getOrigHeight() -> CGFloat {
        return CGFloat(_level._height) * _baseScale * _origScale
    }
    
    // -----------------------------------------------------------------------
    
    func resetBall(instantly instantly: Bool = false, shouldKill: Bool = false, shouldCharge: Bool = false) {
        if shouldKill {
            let path = NSBundle.mainBundle().pathForResource("Explosion", ofType: "sks")
            let particle = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as! SKEmitterNode
            particle.position = _ball.position
            particle.zPosition = 15
            particle.setScale(0.1)
            self.addChild(particle)
        }
        
        if shouldCharge && !(_parent is InstructionsScene) {
            Storage.addStars(-1)
            if let playScene = _parent as? PlayScene {
                playScene.updateStarLabel()
            }
        }
    
        _ball.reset(true)
        stop()
        _ballX = _level._startX
        _ballY = _level._startY
        _ball.setScale(1)
        _ball.position = CGPoint(x: CGFloat(_ballX) + 0.5, y: CGFloat(_ballY) + 0.5)
        _ball.zRotation = 0
        
        resetView(instantly)
    }
    
    func resetView(instantly: Bool = false, alwaysCenter: Bool = false) {
        if (instantly || _parent is InstructionsScene) {
            setScale(1.0)
        } else {
            var m0: CGFloat = 0
            var m1: CGFloat = 0
            if let playScene = _parent as? PlayScene {
                m0 = playScene._marginRight
                m1 = playScene._marginBottom
            }
            
            if !alwaysCenter &&
               position.x >= 0 &&
               position.x + getWidth() <= _parent.size.width - m0 &&
               position.y >= m1 &&
               position.y + getHeight() <= _parent.size.height {
                return
            }
            
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
    }
    
    func attemptMove(dir: Direction, swipe: CGPoint) {
        // Can't redirect ball while moving
        if _dir != .Still {
            return
        }
        
        // Can't move through walls
        if cannotMove(updateNextPiece(dir), dir: dir) {
            return
        }
        
        // Now that we know this is a valid move...
        _spin = -1
        let ballX = position.x + _ball.position.x * _scale * _baseScale
        let ballY = _parent.frame.height - (position.y + _ball.position.y * _scale * _baseScale)
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
        _ball.stopIdleTimer()
    
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
        _ball.reset()
        _ball.runAction(SKAction.rotateByAngle(_spin * _ballSpinSpeed, duration: _ballSpeed))
        _ball.runAction(SKAction.moveByX(CGFloat(x), y: CGFloat(y), duration: _ballSpeed), completion: doneMoving)
    }
    
    func doneMoving() {
        if _level._correct != nil && _correctIdx < _level._correct!.count {
            let correct = _level._correct![_correctIdx]
            if _ballX == correct.x && _ballY == correct.y {
                _correctIdx += 1
            }
        }
    
        if _nextPiece.contains(.Target) {
            win()
            return
        } else if _nextPiece.contains(.Void) {
            _didEnterVoid = true
            resetBall(shouldKill: true, shouldCharge: true)
            return
        } else if _nextPiece.contains(.Teleporter) {
            teleport()
            if _dir == .Still {
                return
            }
            if cannotMove(updateNextPiece(_dir), dir: _dir) {
                stop(true)
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
        
        if cannotMove(updateNextPiece(_dir), dir: _dir) {
            stop(true)
            return
        }
        
        move(_dir)
    }
    
    func cannotMove(piece: PieceType, dir: Direction) -> Bool {
        if (piece.contains(.Block)) ||
           (piece.contains(.Corner1) && (dir == .Right || dir == .Up))   ||
           (piece.contains(.Corner2) && (dir == .Up    || dir == .Left)) ||
           (piece.contains(.Corner3) && (dir == .Left  || dir == .Down)) ||
           (piece.contains(.Corner4) && (dir == .Down  || dir == .Right)) {
            return true
        }
        return false
    }
    
    func getNextPiece(x x: Int, y: Int) -> PieceType {
        return _level.getPieceSafely((x: x, y: y))
    }
    
    func getNextPiece(x x: Int, y: Int, dir: Direction) -> PieceType {
        switch dir {
        case .Right: return getNextPiece(x: x + 1, y: y)
        case .Up:    return getNextPiece(x: x, y: y + 1)
        case .Left:  return getNextPiece(x: x - 1, y: y)
        case .Down:  return getNextPiece(x: x, y: y - 1)
        default:     return getNextPiece(x: x, y: y)
        }
    }
    
    func updateNextPiece(x x: Int, y: Int) -> PieceType {
        _nextPiece = getNextPiece(x: x, y: y)
        return _nextPiece
    }
    
    func updateNextPiece(dir: Direction) -> PieceType {
        _nextPiece = getNextPiece(x: _ballX, y: _ballY, dir: dir)
        return _nextPiece
    }
    
    func teleport() {
        let dst = _level.getTeleporterPair(x: _ballX, y: _ballY)
        if dst.x < 0 {
            resetBall()
            return
        }
        _ballX = dst.x
        _ballY = dst.y
        _ball.position = CGPoint(x: CGFloat(_ballX) + 0.5, y: CGFloat(_ballY) + 0.5)
    }
    
    func stop(animated: Bool = false) {
        if animated {
            _ball.stop(dir: _dir, dtheta: _spin * _ballSpinSpeed, dt: _ballSpeed)
        } else {
            _ball.startIdleTimer()
        }
        _dir = .Still
    }
    
    func win() {
        _ball.runAction(SKAction.rotateByAngle(_spin * _ballSpinSpeed, duration: _winDuration))
        _ball.runAction(SKAction.scaleTo(0.01, duration: _winDuration), completion: { () -> Void in
            if (self._winCallback != nil) {
                (self._winCallback!)()
            }
        })
    }
    
    func canHint() -> Bool {
        if Storage.loadStars() < Constants.HINT_COST || _level is CustomLevel || _level._correct != nil && _correctIdx >= _level._correct!.count {
            return false
        }
        return true
    }
    
    func hint() {
        _correctIdx += 3
        drawPath(_correctIdx)
    }
    
    func changeSize() {
        var m0: CGFloat = 0
        var m1: CGFloat = 0
        if let playScene = _parent as? PlayScene {
            m0 = playScene._marginRight
            m1 = playScene._marginBottom
        }
        _origX = (_parent.frame.width - m0 - getOrigWidth()) / 2
        _origY = (_parent.frame.height - m1 - getOrigHeight()) / 2 + m1
    }
}
