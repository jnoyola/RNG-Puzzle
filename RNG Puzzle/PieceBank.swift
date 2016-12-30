//
//  PieceBank.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 3/29/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import SpriteKit

class PieceBank: SKShapeNode {

    var _parent: CreationScene! = nil
    var _level: LevelProtocol! = nil
    var _cornerRadius: CGFloat = 0
    
    var _cancelLabel: SKLabelNode! = nil
    var _finishLabel: SKLabelNode! = nil
    var _isMenu = true
    
    var _pieceNodes = [SKNode]()
    var _pieceTypes = [PieceType]()

    init(parent: CreationScene, level: LevelProtocol, cornerRadius: CGFloat = 10) {
        super.init()
        
        _parent = parent
        _level = level
        
        _cornerRadius = cornerRadius
        fillColor = UIColor.white
        zPosition = 14
        
        createMenu()
        createPieces()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createMenu() {
        _cancelLabel = addLabel("Cancel", color: SKColor.black)
        _finishLabel = addLabel("Finish", color: SKColor.black)
    }
    
    func addLabel(_ text: String, color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: Constants.FONT)
        label.text = text
        label.fontColor = color
        addChild(label)
        return label
    }
    
    func createPieces() {
        let sprites = PieceSprites()
        
        addPiece(texture: sprites.block(), type: .Block)
        addPiece(texture: sprites.corner1(), type: .Corner1)
        addPiece(texture: sprites.corner2(), type: .Corner2)
        addPiece(texture: sprites.corner3(), type: .Corner3)
        addPiece(texture: sprites.corner4(), type: .Corner4)
        
        let nodeNone = SKShapeNode(rectOf: CGSize(width: 1, height: 1))
        nodeNone.lineWidth = 0
        nodeNone.fillColor = Constants.colorForLevel(_level._level)
        nodeNone.isAntialiased = false
        nodeNone.zPosition = 15
        nodeNone.isHidden = true
        _pieceNodes.append(nodeNone)
        _pieceTypes.append(.None)
        
        addPiece(node: Blob(animated: false), type: .Used)
        addPiece(texture: sprites.target(), type: .Target)
        addPiece(texture: sprites.teleporter(), type: .Teleporter)
        
        let nodeMore = SKSpriteNode(imageNamed: "More")
//        nodeMore.color = UIColor.blackColor()
//        nodeMore.colorBlendFactor = 1
        nodeMore.size = CGSize(width: 1, height: 1)
        nodeMore.zPosition = 15
        nodeMore.isHidden = true
        _pieceNodes.append(nodeMore)
        _pieceTypes.append(.Stop)
    }
    
    func addPiece(texture: SKTexture, type: PieceType) {
        let node = SKSpriteNode(texture: texture)
        node.size = CGSize(width: 1, height: 1)
        addPiece(node: node, type: type)
    }
    
    func addPiece(node: SKSpriteNode, type: PieceType) {
        node.zPosition = 15
        node.isHidden = true
        _pieceNodes.append(node)
        _pieceTypes.append(type)
    }
    
    func selectAtPoint(x: CGFloat, y: CGFloat) -> PieceType? {
        let x = x - position.x
        let y = y - position.y
        if _isMenu {
            if isPointInBounds(x: x, y: y, node: _cancelLabel) {
                cancel()
            } else if isPointInBounds(x: x, y: y, node: _finishLabel) {
                finish()
            }
        } else {
            for i in (0..._pieceNodes.count - 1) {
                if !_pieceNodes[i].isHidden && isPointInBounds(x: x, y: y, node: _pieceNodes[i]) {
                    return _pieceTypes[i]
                }
            }
        }
        return nil
    }
    
    func isPointInBounds(x: CGFloat, y: CGFloat, node: SKNode) -> Bool {
        let margin: CGFloat = node is SKLabelNode ? 2.0 : 0.25
        let x1 = node.frame.minX - node.frame.width / 4
        let x2 = node.frame.maxX + node.frame.width / 4
        let y1 = node.frame.minY - node.frame.height * margin
        let y2 = node.frame.maxY + node.frame.height * margin
        if x > x1 && x < x2 && y > y1 && y < y2 {
            return true
        }
        return false
    }
    
    func allowPieces(_ pieces: Set<Int>?) {
        if pieces == nil {
            _isMenu = true
            
            _cancelLabel.isHidden = false
            _finishLabel.isHidden = false
            
            for i in 0...(_pieceNodes.count - 1) {
                _pieceNodes[i].isHidden = true
            }
            
        } else {
            _isMenu = false
            
            _cancelLabel.isHidden = true
            _finishLabel.isHidden = true
            
            for i in 0...(_pieceTypes.count - 1) {
                if _pieceTypes[i] == .None ||
                   _pieceTypes[i] == .Stop ||
                   pieces!.contains(_pieceTypes[i].rawValue) {
                    _pieceNodes[i].isHidden = false
                } else {
                    _pieceNodes[i].isHidden = true
                }
                
                if _pieceTypes[i] == .None {
                    (_pieceNodes[i] as? SKShapeNode)?.fillColor = Constants.colorForLevel(_level._level)
                }
            }
        }
    }
    
    func cancel() {
        AlertManager.defaultManager().creationCancelWarning(scene: _parent)
    }
    
    func finish() {
        _parent.finishPress()
    }

    func refreshLayout(size: CGSize) -> (CGFloat, CGFloat) {
        removeAllChildren()
        
        let w = size.width
        let h = size.height
        if w < h {
            let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: w, height: 3.5 * (w / 8)))
            self.path = CGPath(roundedRect: rect, cornerWidth: _cornerRadius, cornerHeight: _cornerRadius, transform: nil)
            position = CGPoint.zero
            
            _cancelLabel.fontSize = w * 0.064
            _cancelLabel.position = CGPoint(x: w * 0.25, y: 0.45 * 3.5 * w / 8)
            addChild(_cancelLabel)
            
            _finishLabel.fontSize = w * 0.064
            _finishLabel.position = CGPoint(x: w * 0.75, y: 0.45 * 3.5 * w / 8)
            addChild(_finishLabel)
            
            for i in 0...4 {
                _pieceNodes[i].setScale(w / 8)
                _pieceNodes[i].position = CGPoint(x: (CGFloat(i) * 1.5 + 1) * w / 8, y: 2.5 * w / 8)
                addChild(_pieceNodes[i])
            }
            for i in 5...9 {
                _pieceNodes[i].setScale(w / 8)
                _pieceNodes[i].position = CGPoint(x: (CGFloat(i - 5) * 1.5 + 1) * w / 8, y: w / 8)
                addChild(_pieceNodes[i])
            }
            
            return (0, rect.height)
        } else {
            let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: 3.5 * (h / 8), height: h))
            self.path = CGPath(roundedRect: rect, cornerWidth: _cornerRadius, cornerHeight: _cornerRadius, transform: nil)
            position = CGPoint(x: w - rect.width, y: 0)
            
            _cancelLabel.fontSize = h * 0.064
            _cancelLabel.position = CGPoint(x: 0.5 * 3.5 * h / 8, y: 0.25 * h)
            addChild(_cancelLabel)
            
            _finishLabel.fontSize = h * 0.064
            _finishLabel.position = CGPoint(x: 0.5 * 3.5 * h / 8, y: 0.75 * h)
            addChild(_finishLabel)
            
            for i in 0...4 {
                _pieceNodes[i].setScale(h / 8)
                _pieceNodes[i].position = CGPoint(x: h / 8, y: (CGFloat(i) * 1.5 + 1) * h / 8)
                addChild(_pieceNodes[i])
            }
            for i in 5...9 {
                _pieceNodes[i].setScale(h / 8)
                _pieceNodes[i].position = CGPoint(x: 2.5 * h / 8, y: (CGFloat(i - 5) * 1.5 + 1) * h / 8)
                addChild(_pieceNodes[i])
            }
            
            return (rect.width, 0)
        }
    }
}
