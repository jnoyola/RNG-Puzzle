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

    var _editIndex = -1

    var _pieceBank: PieceBank! = nil
    
    var _isMenu = true
    var _sizeButtons = [SKSpriteNode?](repeating: nil, count: 8)

    override func createGameView() {
        _gameView = CreationView(level: _level, parent: self, winCallback: complete)
        addChild(_gameView)
    }
    
    override func createHUD() {
        _pieceBank = PieceBank(parent: self, level: _level)
        addChild(_pieceBank)
        
        for i in 0...7 {
            let node = SKSpriteNode(imageNamed: i % 2 == 0 ? "Add" : "Remove")
            node.zPosition = 15
            _sizeButtons[i] = node
            self.addChild(node)
        }
        showSizeButtons(true)
    }

    override func handleTap(sender: UITapGestureRecognizer) {
        let p = sender.location(in: sender.view)
        let x = p.x
        let y = size.height - p.y
        
        if _isMenu {
            for i in 0...(_sizeButtons.count - 1) {
                if let sizeButton = _sizeButtons[i] {
                    if !sizeButton.isHidden && isPointInBounds(x: x, y: y, node: sizeButton) {
                        performSizeAction(i)
                        return
                    }
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
    
    func isPointInBounds(x: CGFloat, y: CGFloat, node: SKNode) -> Bool {
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
    
    override func update(_ currentTime: TimeInterval) {}
    
    override func refreshHUD() {
        (_marginRight, _marginBottom) = _pieceBank.refreshLayout(size: size)
        refreshSizeButtons()
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
            sizeButton?.size = CGSize(width: buttonSize, height: buttonSize)
        }
        
        _sizeButtons[0]?.position = CGPoint(x: x_left, y: y_mid + dist)
        _sizeButtons[1]?.position = CGPoint(x: x_left, y: y_mid - dist)
        
        _sizeButtons[2]?.position = CGPoint(x: x_right, y: y_mid + dist)
        _sizeButtons[3]?.position = CGPoint(x: x_right, y: y_mid - dist)
        
        _sizeButtons[4]?.position = CGPoint(x: x_mid + dist, y: y_bot)
        _sizeButtons[5]?.position = CGPoint(x: x_mid - dist, y: y_bot)
        
        _sizeButtons[6]?.position = CGPoint(x: x_mid + dist, y: y_top)
        _sizeButtons[7]?.position = CGPoint(x: x_mid - dist, y: y_top)
    }
    
    func showSizeButtons(_ show: Bool) {
        _isMenu = show
        if show {
            let customLevel = _level as! CustomLevel
            _sizeButtons[0]?.isHidden = !customLevel.canIncWidth()
            _sizeButtons[1]?.isHidden = !customLevel.canDecWidth()
            
            _sizeButtons[2]?.isHidden = !customLevel.canIncWidth()
            _sizeButtons[3]?.isHidden = !customLevel.canDecWidth()
            
            _sizeButtons[4]?.isHidden = !customLevel.canIncHeight()
            _sizeButtons[5]?.isHidden = !customLevel.canDecHeight()
            
            _sizeButtons[6]?.isHidden = !customLevel.canIncHeight()
            _sizeButtons[7]?.isHidden = !customLevel.canDecHeight()
        } else {
            for sizeButton in _sizeButtons {
                sizeButton?.isHidden = true
            }
        }
    }
    
    func performSizeAction(_ action: Int) {
        switch action {
        case 0:
            _gameView.position = CGPoint(x: _gameView.position.x - _gameView.getWidth() / CGFloat(_level._width), y: _gameView.position.y)
            (_level as! CustomLevel).incLeft()
            if _gameView._ballX >= 0 {
                _gameView._ballX += 1
            } else {
                _gameView.resetBall()
            }
        case 1:
            _gameView.position = CGPoint(x: _gameView.position.x + _gameView.getWidth() / CGFloat(_level._width), y: _gameView.position.y)
            (_level as! CustomLevel).decLeft()
            if _gameView._ballX >= 0 {
                _gameView._ballX -= 1
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
                _gameView._ballY += 1
            } else {
                _gameView.resetBall()
            }
        case 5:
            _gameView.position = CGPoint(x: _gameView.position.x, y: _gameView.position.y + _gameView.getHeight() / CGFloat(_level._height))
            (_level as! CustomLevel).decBottom()
            if _gameView._ballY >= 0 {
                _gameView._ballY -= 1
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
    
        refreshSizeButtons()
    }
    
    func finishPress() {
        let numSolutions = _level.getNumSolutions()
        let name = _editIndex < 0 ? "" : Storage.loadCustomLevelNames()[_editIndex] as String
        if (_level as! CustomLevel)._teleporters.count % 2 == 1 {
            AlertManager.defaultManager().alert("You must place or remove a wormhole.")
        } else if numSolutions < 1 {
            AlertManager.defaultManager().alert("Your puzzle does not have a solution.")
        } else {
            AlertManager.defaultManager().creationFinishWarning(scene: self, numSolutions: numSolutions, name: name)
        }
    }
    
    func finishDone(name: String) {
        (_level as! CustomLevel).computeSeed()
        if _editIndex < 0 {
            Storage.saveCustomLevel(_level, name: name)
        } else {
            Storage.editCustomLevel(_level, name: name, index: _editIndex)
        }
        
        AppDelegate.popViewController(animated: true)
    }
    
    func cancelDone() {
        AppDelegate.popViewController(animated: true)
    }
}
