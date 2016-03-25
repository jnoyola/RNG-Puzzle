//
//  CoinLabel.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 3/25/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit

class CoinLabel: SKNode {

    var _minX: CGFloat = 0
    var _maxX: CGFloat = 0
    var _minY: CGFloat = 0
    var _maxY: CGFloat = 0
    
    init(text: String, size: CGFloat, color: SKColor, coinScale: CGFloat = 2.3, anchor: NSTextAlignment = .Center) {
        super.init()
        
        let coin = SKSpriteNode(imageNamed: "coin")
        let coinHeight = size * coinScale
        let coinWidth = coinHeight * 0.6
        coin.size = CGSize(width: coinWidth, height: coinHeight)
        
        let label = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        label.text = text
        label.fontSize = size
        label.fontColor = color
        label.horizontalAlignmentMode = .Center
        
        let pad = size * 0.5
        
        switch anchor {
        case .Center:
            coin.position = CGPoint(x: -pad - label.frame.size.width / 2, y: size * 0.5 + (3 - 6.9 / coinScale))
            label.position = CGPoint(x: coinWidth / 2, y: 0)
        case .Left:
            coin.position = CGPoint(x: -pad - coinWidth / 2, y: size * 0.5 + (3 - 6.9 / coinScale))
            label.position = CGPoint(x: label.frame.size.width / 2, y: 0)
        default:
            break
        }
        _minX = min(coin.frame.minX, label.frame.maxX)
        _maxX = max(coin.frame.maxX, label.frame.maxX)
        _minY = min(coin.frame.minY, label.frame.maxY)
        _maxY = max(coin.frame.maxY, label.frame.maxY)
        
        addChild(coin)
        addChild(label)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func animate() {
        let path = NSBundle.mainBundle().pathForResource("Sparks", ofType: "sks")
        let particle = NSKeyedUnarchiver.unarchiveObjectWithFile(path!) as! SKEmitterNode
        particle.zPosition = 200
            
        self.addChild(particle)
    }
}
