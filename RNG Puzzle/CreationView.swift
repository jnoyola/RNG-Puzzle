//
//  CreationView.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 3/28/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import SpriteKit

class CreationView: GameView {

    typealias Point = (x: Int, y: Int)

    var _selectedPoint: Point? = nil
    var _selectionSquare: SKShapeNode! = nil

    override func drawPieces(level: LevelProtocol) {
        super.drawPieces(level)
        
        if level._startX >= 0 {
            let start = Blob(animated: false)
            start.color = SKColor.blackColor()
            start.colorBlendFactor = 0.9
            start.size = CGSize(width: 1, height: 1)
            start.position = CGPoint(x: CGFloat(level._startX) + 0.5, y: CGFloat(level._startY) + 0.5)
            start.zPosition = 0
            addChild(start)
        }
        
        _selectionSquare = SKShapeNode(rectOfSize: CGSize(width: 2.2, height: 2.2))
        _selectionSquare.strokeColor = UIColor.whiteColor()
        _selectionSquare.lineWidth = 0.1
        _selectionSquare.setScale(0.5)
        _selectionSquare.antialiased = false
        _selectionSquare.zPosition = 15
    }
    
    func selectAtPoint(x x: CGFloat, y: CGFloat) -> Set<Int>? {
        
        let p = getCoordsOfPoint(x: x, y: y)
        if p.x >= 0 && p.x < _level._width && p.y >= 0 && p.y < _level._height {
            _selectionSquare.removeFromParent()
            _selectedPoint = p
            markSelected()
            return getAllowedPieces(p)
        } else {
            deselect()
            return nil
        }
    }
    
    func markSelected() {
        if _selectedPoint == nil {
            return
        }
        _selectionSquare.position = CGPoint(x: CGFloat(_selectedPoint!.x) + 0.5, y: CGFloat(_selectedPoint!.y) + 0.5)
        addChild(_selectionSquare)
    }
    
    func selectPiece(piece: PieceType) -> Set<Int>? {
        if piece == .Stop || _selectedPoint == nil {
            deselect()
            return nil
        }
        
        let customLevel = (_level as! CustomLevel)
        
        // If we're overwriting a teleporter, remove its pair
        // If we're overwriting the start, reset its coordinates
        // If we're overwriting the target, reset its coordinates
        let oldPiece = _level.getPiece(x: _selectedPoint!.x, y: _selectedPoint!.y)
        if oldPiece == .Teleporter {
            customLevel.removeTeleporter(_selectedPoint!)
        } else if oldPiece == .Used {
            customLevel._startX = -1
            customLevel._startY = -1
        } else if oldPiece == .Target {
            customLevel._targetX = -1
            customLevel._targetY = -1
        }
        
        // Place new piece
        customLevel.setPiece(x: _selectedPoint!.x, y: _selectedPoint!.y, type: piece)
        
        // If we're placing a teleporter, add it to the list
        // If we're placing the start, maybe remove the old start
        // If we're placing the target, maybe remove the old target
        if piece == .Teleporter {
            customLevel._teleporters.append(_selectedPoint!)
        } else if piece == .Used {
            if customLevel._startX >= 0 {
                customLevel.setPiece(x: customLevel._startX, y: customLevel._startY, type: .None)
            }
            customLevel._startX = _selectedPoint!.x
            customLevel._startY = _selectedPoint!.y
            
            resetBall()
        } else if piece == .Target {
            if customLevel._targetX >= 0 {
                customLevel.setPiece(x: customLevel._targetX, y: customLevel._targetY, type: .None)
            }
            customLevel._targetX = _selectedPoint!.x
            customLevel._targetY = _selectedPoint!.y
        }
        
        // Reset the ball if we're placing a piece at its position
        if _ballX == _selectedPoint!.x && _ballY == _selectedPoint!.y {
            resetBall()
        }
        
        removeAllChildren()
        drawLevel(_level)
        markSelected()
        if _ballX >= 0 {
            addChild(_ball)
        }
    
        return getAllowedPieces(_selectedPoint!)
    }
    
    func getAllowedPieces(point: Point) -> Set<Int> {
    
        var pieces = Set<Int>()
        pieces.insert(PieceType.Teleporter.rawValue)
    
        // Check if we need to place a teleporter
        if (_level as! CustomLevel)._teleporters.count % 2 == 1 {
            return pieces
        }
        
        // Check if we've already exhausted all teleporter IDs
        if (_level as! CustomLevel)._teleporters.count >= 64 {
            pieces.popFirst()
        }
        
        pieces.insert(PieceType.Block.rawValue)
        pieces.insert(PieceType.Corner1.rawValue)
        pieces.insert(PieceType.Corner2.rawValue)
        pieces.insert(PieceType.Corner3.rawValue)
        pieces.insert(PieceType.Corner4.rawValue)
        pieces.insert(PieceType.Used.rawValue)
        pieces.insert(PieceType.Target.rawValue)
        
        // For each direction, 
        // ensure that we don't place a wall in front of a corner
        // and that we don't place a corner that feeds into a wall
        var nextPiece = getNextPiece(x: point.x, y: point.y, dir: .Right)
        if nextPiece == .Corner2 || nextPiece == .Corner3 {
            pieces.remove(PieceType.Block.rawValue)
            pieces.remove(PieceType.Corner2.rawValue)
            pieces.remove(PieceType.Corner3.rawValue)
        } else if nextPiece == .Block || nextPiece == .Corner1 || nextPiece == .Corner4 {
            pieces.remove(PieceType.Corner1.rawValue)
            pieces.remove(PieceType.Corner4.rawValue)
        }
        nextPiece = getNextPiece(x: point.x, y: point.y, dir: .Up)
        if nextPiece == .Corner3 || nextPiece == .Corner4 {
            pieces.remove(PieceType.Block.rawValue)
            pieces.remove(PieceType.Corner3.rawValue)
            pieces.remove(PieceType.Corner4.rawValue)
        } else if nextPiece == .Block || nextPiece == .Corner1 || nextPiece == .Corner2 {
            pieces.remove(PieceType.Corner1.rawValue)
            pieces.remove(PieceType.Corner2.rawValue)
        }
        nextPiece = getNextPiece(x: point.x, y: point.y, dir: .Left)
        if nextPiece == .Corner1 || nextPiece == .Corner4 {
            pieces.remove(PieceType.Block.rawValue)
            pieces.remove(PieceType.Corner1.rawValue)
            pieces.remove(PieceType.Corner4.rawValue)
        } else if nextPiece == .Block || nextPiece == .Corner2 || nextPiece == .Corner3 {
            pieces.remove(PieceType.Corner2.rawValue)
            pieces.remove(PieceType.Corner3.rawValue)
        }
        nextPiece = getNextPiece(x: point.x, y: point.y, dir: .Down)
        if nextPiece == .Corner1 || nextPiece == .Corner2 {
            pieces.remove(PieceType.Block.rawValue)
            pieces.remove(PieceType.Corner1.rawValue)
            pieces.remove(PieceType.Corner2.rawValue)
        } else if nextPiece == .Block || nextPiece == .Corner3 || nextPiece == .Corner4 {
            pieces.remove(PieceType.Corner3.rawValue)
            pieces.remove(PieceType.Corner4.rawValue)
        }
    
        return pieces
    }
    
    func getCoordsOfPoint(x x: CGFloat, y: CGFloat) -> Point {
        let w = getWidth()
        let h = getHeight()
        
        // Floor so that negative values aren't rounded up towards 0
        let x = Int(floor((x - position.x) * CGFloat(_level._width) / w))
        let y = Int(floor((y - position.y) * CGFloat(_level._height) / h))
        return (x: x, y: y)
    }
    
    override func attemptMove(dir: Direction, swipe: CGPoint) {
        if _ball.parent != nil {
            super.attemptMove(dir, swipe: swipe)
        }
    }
    
    override func resetBall(instantly instantly: Bool = false, shouldKill: Bool = false, shouldCharge: Bool = false) {
        super.resetBall(instantly: instantly)
        
        if _ballX < 0 {
            _ball.removeFromParent()
        }
    }
    
    func deselect() {
        _selectionSquare.removeFromParent()
        _selectedPoint = nil
    }
    
    func levelSizeChanged() {
        resetBaseScale()
        changeSize()
        resetView(alwaysCenter: true)
        removeAllChildren()
        drawLevel(_level)
        if _ballX >= 0 && _ballX < _level._width && _ballY >= 0 && _ballY < _level._height {
            _ball.position = CGPoint(x: CGFloat(_ballX) + 0.5, y: CGFloat(_ballY) + 0.5)
            addChild(_ball)
        }
    }
}
