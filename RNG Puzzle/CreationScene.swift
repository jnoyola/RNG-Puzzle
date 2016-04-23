//
//  CreationScene.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 3/28/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit

class CreationScene: PlayScene {

    var _pieceBank: PieceBank! = nil
    
    var _isMenu = true
    var _sizeButtons = [SKSpriteNode!](count: 8, repeatedValue: nil)

    override func createGameView() {
        _pieceBank = PieceBank(parent: self)
        refreshPieceBank()
        addChild(_pieceBank)
        
        _gameView = CreationView(level: _level, parent: self, winCallback: complete)
        addChild(_gameView)
        
        for i in 0...7 {
            let node = SKSpriteNode(imageNamed: i % 2 == 0 ? "Add" : "Remove")
            node.zPosition = 15
            _sizeButtons[i] = node
            self.addChild(node)
        }
        refreshSizeButtons()
        showSizeButtons(true)
    }

    override func handleTap(sender: UITapGestureRecognizer) {
        let p = sender.locationInView(sender.view)
        let x = p.x
        let y = size.height - p.y
        
        if _isMenu {
            for i in 0...(_sizeButtons.count - 1) {
                if !_sizeButtons[i].hidden && isPointInBounds(x: x, y: y, node: _sizeButtons[i]) {
                    performSizeAction(i)
                    return
                }
            }
        }
        
        if y > _marginBottom && x < size.width - _marginRight {
            let nextPieces = (_gameView as! CreationView).selectAtPoint(x: x, y: y)
            _pieceBank.allowPieces(nextPieces)
            showSizeButtons(nextPieces == nil)
        } else {
            let piece = _pieceBank.selectAtPoint(x: x, y: y)
            if piece != nil {
                let nextPieces = (_gameView as! CreationView).selectPiece(piece!)
                _pieceBank.allowPieces(nextPieces)
                showSizeButtons(nextPieces == nil)
            }
        }
    }
    
    func isPointInBounds(x x: CGFloat, y: CGFloat, node: SKNode) -> Bool {
        let x1 = node.frame.minX - node.frame.width / 2
        let x2 = node.frame.maxX + node.frame.width / 2
        let y1 = node.frame.minY - node.frame.height / 2
        let y2 = node.frame.maxY + node.frame.height / 2
        if x > x1 && x < x2 && y > y1 && y < y2 {
            return true
        }
        return false
    }
    
    override func complete() {
        _gameView._dir = .Still
        _gameView._ball.setScale(1.0)
        _gameView.resetBall()
    }
    
    override func startTimer() {}
    
    override func refreshCoins() {}
    
    override func refreshTimer() {}
    
    func refreshPieceBank() {
        (_marginRight, _marginBottom) = _pieceBank.refreshLayout(size)
    }
    
    func refreshSizeButtons() {
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        let buttonSize = s * 0.1
        let pad = s * 0.05
        
        let x_left = pad + buttonSize / 2
        let x_mid = (w - _marginRight) / 2
        let x_right = w - _marginRight - pad - buttonSize / 2
        let y_bot = _marginBottom + pad + buttonSize / 2
        let y_mid = _marginBottom + (h - _marginBottom) / 2
        let y_top = h - pad - buttonSize / 2
        let dist = pad + buttonSize / 2
        
        for sizeButton in _sizeButtons {
            sizeButton.size = CGSize(width: buttonSize, height: buttonSize)
        }
        
        _sizeButtons[0].position = CGPoint(x: x_left, y: y_mid + dist)
        _sizeButtons[1].position = CGPoint(x: x_left, y: y_mid - dist)
        
        _sizeButtons[2].position = CGPoint(x: x_right, y: y_mid + dist)
        _sizeButtons[3].position = CGPoint(x: x_right, y: y_mid - dist)
        
        _sizeButtons[4].position = CGPoint(x: x_mid + dist, y: y_bot)
        _sizeButtons[5].position = CGPoint(x: x_mid - dist, y: y_bot)
        
        _sizeButtons[6].position = CGPoint(x: x_mid + dist, y: y_top)
        _sizeButtons[7].position = CGPoint(x: x_mid - dist, y: y_top)
    }
    
    func showSizeButtons(show: Bool) {
        _isMenu = show
        if show {
            let customLevel = _level as! CustomLevel
            _sizeButtons[0].hidden = !customLevel.canIncWidth()
            _sizeButtons[1].hidden = !customLevel.canDecWidth()
            
            _sizeButtons[2].hidden = !customLevel.canIncWidth()
            _sizeButtons[3].hidden = !customLevel.canDecWidth()
            
            _sizeButtons[4].hidden = !customLevel.canIncHeight()
            _sizeButtons[5].hidden = !customLevel.canDecHeight()
            
            _sizeButtons[6].hidden = !customLevel.canIncHeight()
            _sizeButtons[7].hidden = !customLevel.canDecHeight()
        } else {
            for sizeButton in _sizeButtons {
                sizeButton.hidden = true
            }
        }
    }
    
    func performSizeAction(action: Int) {
        switch action {
        case 0:
            _gameView.position = CGPoint(x: _gameView.position.x - _gameView.getWidth() / CGFloat(_level._width), y: _gameView.position.y)
            (_level as! CustomLevel).incLeft()
            if _gameView._ballX >= 0 {
                ++_gameView._ballX
            } else {
                _gameView.resetBall()
            }
        case 1:
            _gameView.position = CGPoint(x: _gameView.position.x + _gameView.getWidth() / CGFloat(_level._width), y: _gameView.position.y)
            (_level as! CustomLevel).decLeft()
            if _gameView._ballX >= 0 {
                --_gameView._ballX
            } else {
                _gameView.resetBall()
            }
        case 2: (_level as! CustomLevel).incRight()
        case 3: (_level as! CustomLevel).decRight()
            if _gameView._ballX >= _level._width {
                _gameView.resetBall()
            }
        case 4:
            _gameView.position = CGPoint(x: _gameView.position.x, y: _gameView.position.y - _gameView.getHeight() / CGFloat(_level._height))
            (_level as! CustomLevel).incBottom()
            if _gameView._ballY >= 0 {
                ++_gameView._ballY
            } else {
                _gameView.resetBall()
            }
        case 5:
            _gameView.position = CGPoint(x: _gameView.position.x, y: _gameView.position.y + _gameView.getHeight() / CGFloat(_level._height))
            (_level as! CustomLevel).decBottom()
            if _gameView._ballY >= 0 {
                --_gameView._ballY
            } else {
                _gameView.resetBall()
            }
        case 6: (_level as! CustomLevel).incTop()
        case 7: (_level as! CustomLevel).decTop()
            if _gameView._ballY >= _level._height {
                _gameView.resetBall()
            }
        default: break
        }
        showSizeButtons(_isMenu)
        (_gameView as! CreationView).levelSizeChanged()
    }
    
    override func changedSize() {
        super.changedSize()
        
        refreshPieceBank()
        refreshSizeButtons()
    }
    
    func finishPress() {
        let numSolutions = _level.getNumSolutions()
        if numSolutions < 1 {
            AlertManager.defaultManager().alert("Your puzzle does not have a solution.")
        } else {
            AlertManager.defaultManager().creationFinishWarning(self, numSolutions: numSolutions)
        }
    }
    
    func finishDone(name: String) {
        (_level as! CustomLevel).computeSeed()
        Storage.saveCustomLevel(_level, name: name)
        
        (UIApplication.sharedApplication().delegate!.window!!.rootViewController! as! UINavigationController).popViewControllerAnimated(true)
    }
    
    func cancelDone() {
        (UIApplication.sharedApplication().delegate!.window!!.rootViewController! as! UINavigationController).popViewControllerAnimated(true)
    }
}
