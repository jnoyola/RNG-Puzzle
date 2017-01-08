//
//  Planet.swift
//  Astro Maze
//
//  Created by Jonathan Noyola on 7/22/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import SpriteKit

class PlanetDisplay: SKNode {

    let _taunts = [
        "Don't worry, it gets much harder",
        "Enjoy the easy ones while you can",
        "I really hope you haven't died already",
        "Are you using the old noggin yet?",
        "Starting to get difficult?",
        "It took you that long to get here?",
        "Think you can go much further?",
        "Now you're getting somewhere",
        "OK, you must be cheating",
        "I wonder what lies beyond...",
        "Alright, you're on your own from here"
    ]

    var _baseLevel = 0
    var _scale: CGFloat = 1
    var _showStars = true
    var _showLevels = true
    var _showTaunt = true

    var _planet: Planet! = nil
    var _rad: CGFloat = 0
    var _levelLabels: [SKLabelNode]! = nil
    var _levelStars: [[SKSpriteNode]]! = nil
    var _tauntLabel: SKLabelNode? = nil
    
    var _labelOffsetY: CGFloat = 0
    
    var _sample: GameSample? = nil
    var _sampleWidth: CGFloat = 0

    init(baseLevel: Int, showStars: Bool, showLevels: Bool, showTaunt: Bool) {
        super.init()
        
        _baseLevel = baseLevel
        _showStars = showStars
        _showLevels = showLevels
        _showTaunt = showTaunt
        _scale = 0.2 + CGFloat(baseLevel % 7) * 0.03
        
        _planet = Planet(baseLevel: baseLevel)
        addChild(_planet)
        
        if _showLevels {
            addLevelMarkers()
        }
        
        maybeAddTaunt()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func addLevelMarkers() {
        _levelLabels = [SKLabelNode]()
        _levelStars = [[SKSpriteNode]]()
        for i in 1...10 {
            let label = SKLabelNode(fontNamed: Constants.FONT)
            label.text = "\(_baseLevel + i)"
            addChild(label)
            _levelLabels.append(label)
            _levelStars.append([SKSpriteNode]())
        }
        
        refreshLevelMarkers()
    }
    
    func refreshLevelMarkers() {
        if _showLevels {
            for i in 0 ... 9 {
                let level = _baseLevel + i + 1
                let score = Storage.loadScore(level: level)
                refreshLevelMarker(i, level: level, score: score)
            }
        }
    }
    
    func refreshLevelMarker(_ i: Int, level: Int, score: Int) {
        if _showStars {
            var stars = _levelStars[i]
            if score > 0 {
                for _ in stars.count ..< score {
                    let star = SKSpriteNode(imageNamed: "star")
                    stars.append(star)
                    addChild(star)
                }
            }
            _levelStars[i] = stars
        }

        _levelLabels[i].fontColor = score >= 0 ? UIColor.white : UIColor.darkGray
    }
    
    func maybeAddTaunt() {
        if _showTaunt && Storage.loadScore(level: _baseLevel + 1) >= 0 {
            _tauntLabel = SKLabelNode(fontNamed: Constants.FONT)
            _tauntLabel!.text = _taunts[_baseLevel / 10]
            _tauntLabel!.fontColor = UIColor.white
            addChild(_tauntLabel!)
        }
    }
    
    func refresh(size: CGSize) {
        refreshLevelMarkers()
        
        if _tauntLabel == nil {
            maybeAddTaunt()
        }
        
        refreshLayout(size: size)
    }
    
    func displaySample() {
        let levelNum = _baseLevel + 1 + Int(arc4random_uniform(10))
        _sample = GameSample(levelNum: levelNum, parentScene: parent!.parent! as! SKScene)
        _sample!.zPosition = 100
        _sample!.setScale(0)
        addChild(_sample!)
        
        _sample!.run(SKAction.scale(to: 1, duration: 0.1))
    }
    
    func hideSample() {
        if _sample != nil {
            _sample!.run(SKAction.scale(to: 0, duration: 0.1), completion: {
                self._sample!.removeFromParent()
                self._sample = nil
            })
        }
    }
    
    func hideLevelMarkers(_ shouldHide: Bool, duration: Double) {
        if _showLevels {
            if duration > 0 {
                let action = shouldHide ? SKAction.fadeOut(withDuration: duration) : SKAction.fadeIn(withDuration: duration)
            
                for label in _levelLabels {
                    label.removeAllActions()
                    label.run(action)
                }
                if _showStars {
                    for list in _levelStars {
                        for star in list {
                            star.removeAllActions()
                            star.run(action)
                        }
                    }
                }
                _tauntLabel?.removeAllActions()
                _tauntLabel?.run(action)
            } else {
                for label in _levelLabels {
                    label.removeAllActions()
                    label.alpha = 1
                }
                if _showStars {
                    for list in _levelStars {
                        for star in list {
                            star.removeAllActions()
                            star.alpha = 1
                        }
                    }
                }
                _tauntLabel?.removeAllActions()
                _tauntLabel?.alpha = 1
            }
        }
    }
    
    func tap(x: CGFloat, y: CGFloat) -> Int? {
        if _showLevels {
            var dMin = CGFloat.greatestFiniteMagnitude
            var iMin = 0
            
            for i in 0...9 {
                if _levelLabels[i].alpha < 1 {
                    continue
                }
                
                let p = _levelLabels[i].position
                let d = pow(p.x - x, 2) + pow(p.y + _labelOffsetY - y, 2)
                if d < dMin {
                    dMin = d
                    iMin = i
                }
            }
            
            if dMin < 50 * pow(_labelOffsetY, 2) {
                let level = _baseLevel + iMin + 1
                if level <= Storage.loadMaxLevel() {
                    return level
                }
            } else if (x * x) + (y * y) < dMin {
                return -_baseLevel
            }
        }
        
        return nil
    }
    
    func hold(x: CGFloat, y: CGFloat) -> Bool {
        if (x * x) + (y * y) < _rad * _rad {
            displaySample()
            return true
        }
        return false
    }
    
    func refreshLevelMarker(levelMod: Int, s: CGFloat) {
        let radiusScale: CGFloat = 0.2
        let x1: CGFloat = 0.95
        let x2: CGFloat = 1.2
        let x3: CGFloat = 1.3
        let y1: CGFloat = 1
        let y2: CGFloat = 0.5
        let starWidth = s * 0.05
        var starOffset = starWidth * 1.2
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        switch levelMod {
            case 1: x = -x1; y = y1;  starOffset *= -1
            case 2: x = -x2; y = y2;  starOffset *= -1
            case 3: x = -x3; y = 0;   starOffset *= -1
            case 4: x = -x2; y = -y2; starOffset *= -1
            case 5: x = -x1; y = -y1; starOffset *= -1
            
            case 6: x = x1; y = y1
            case 7: x = x2; y = y2
            case 8: x = x3; y = 0
            case 9: x = x2; y = -y2
            default: x = x1; y = -y1
        }
        
        x *= s * radiusScale
        y *= s * radiusScale
        let fontSize = s * Constants.TEXT_SCALE * 0.6
        _labelOffsetY = fontSize * 0.47
        _levelLabels[levelMod - 1].position = CGPoint(x: x, y: y - _labelOffsetY)
        _levelLabels[levelMod - 1].fontSize = fontSize
        
        if _showStars {
            x += starOffset * 0.25
            let starSize = CGSize(width: starWidth, height: starWidth)
            for star in _levelStars[levelMod - 1] {
                x += starOffset
                star.position = CGPoint(x: x, y: y)
                star.size = starSize
            }
        }
    }
    
    func refreshLayout(size: CGSize) {
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        let dia = s * _scale
        _planet.setSize(CGSize(width: dia, height: dia))
        _rad = dia / 2
        _sampleWidth = s * 0.6
        
        if _showLevels {
            for i in 1...10 {
                refreshLevelMarker(levelMod: i, s: s)
            }
        }
        
        if _tauntLabel != nil {
            let y = (s * -0.27 - h * 0.32) / 2
            _tauntLabel?.fontSize = s * Constants.TEXT_SCALE * 0.6
            _tauntLabel?.position = CGPoint(x: 0, y: y)
        }
    }
}
