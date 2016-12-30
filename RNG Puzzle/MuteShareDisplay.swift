//
//  ShareDisplay.swift
//  Astro Maze
//
//  Created by Jonathan Noyola on 7/29/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import SpriteKit

class MuteShareDisplay: SKNode {

    enum ShareType {
        case App
        case Level
        case Score
    }

    var _shareType: ShareType! = nil
    var _level: LevelProtocol? = nil
    var _duration = 0
    var _score = 0

    var _muteButton: SKSpriteNode! = nil

    var _messagesButton: SKSpriteNode! = nil
    var _facebookButton: SKSpriteNode! = nil
    var _twitterButton: SKSpriteNode! = nil
    
    init(shareType: ShareType, level: LevelProtocol? = nil, duration: Int = 0, score: Int = 0) {
        super.init()
        
        _shareType = shareType
        _level = level
        _duration = duration
        _score = score
        
        _muteButton = SKSpriteNode()
        refreshMuteButton(isMuted: Storage.isMuted())
        addChild(_muteButton)
        
        _messagesButton = SKSpriteNode(imageNamed: "icon_messages")
        _facebookButton = SKSpriteNode(imageNamed: "icon_facebook")
        _twitterButton = SKSpriteNode(imageNamed: "icon_twitter")
        addChild(_messagesButton)
        addChild(_facebookButton)
        addChild(_twitterButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func refreshMuteButton(isMuted: Bool) {
        if isMuted {
            _muteButton.texture = SKTexture(imageNamed: "icon_audio_off")
        } else {
            _muteButton.texture = SKTexture(imageNamed: "icon_audio_on")
        }
    }
    
    func tap(_ p: CGPoint) {
        if isPointInBounds(p, node: _muteButton) {
            refreshMuteButton(isMuted: Storage.toggleMute())
        } else if isPointInBounds(p, node: _facebookButton) {
            AlertManager.defaultManager().shareFacebook(type: _shareType, level: _level, duration: _duration)
        } else if isPointInBounds(p, node: _messagesButton) {
            AlertManager.defaultManager().shareMessages(type: _shareType, level: _level, duration: _duration)
        } else if isPointInBounds(p, node: _twitterButton) {
            AlertManager.defaultManager().shareTwitter(type: _shareType, level: _level, duration: _duration)
        }
    }
    
    func isPointInBounds(_ p: CGPoint, node: SKNode) -> Bool {
        let margin = node.frame.size.width * 0.25
        
        let x1 = node.frame.minX - margin
        let x2 = node.frame.maxX + margin
        let y1 = node.frame.minY - margin
        let y2 = node.frame.maxY + margin
        if p.x > x1 && p.x < x2 && p.y > y1 && p.y < y2 {
            return true
        }
        return false
    }
    
    func refreshLayout(size: CGSize) {
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        let iconWidth = s * Constants.ICON_SCALE
        let iconSize = CGSize(width: iconWidth, height: iconWidth)
        let offset = s * Constants.TEXT_SCALE
        
        _muteButton.size = iconSize
        _muteButton.position = CGPoint(x: offset, y: offset)
        
        _messagesButton.size = iconSize
        _messagesButton.position = CGPoint(x: w - offset - s * 0.32, y: offset)
        
        _facebookButton.size = iconSize
        _facebookButton.position = CGPoint(x: w - offset - s * 0.16, y: offset)
        
        _twitterButton.size = iconSize
        _twitterButton.position = CGPoint(x: w - offset, y: offset)
    }
}
