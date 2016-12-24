//
//  Planet.swift
//  Astro Maze
//
//  Created by Jonathan Noyola on 7/23/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import SceneKit
import SpriteKit

class Planet: SKNode {

    let _numPlanets = 6
    let _numRings = 2
    let _blend: CGFloat = 1.0
    let _ringBlend: CGFloat = 0.6
    
    var _planet: SKSpriteNode! = nil
    var _top: SKSpriteNode? = nil
    var _bot: SKSpriteNode? = nil
    
    init(baseLevel: Int) {
        super.init()
        
        let planetIdx = (baseLevel / 10) % _numPlanets
        let ringIdx = (baseLevel * 5 / 10) % (_numPlanets - 2)
        let color = Constants.colorForLevel(baseLevel + 5)
        let angle = CGFloat((baseLevel * 11 / 10) % 8) * 0.07 - 0.25
        
        createPlanet(planetIdx, ringIdx: ringIdx, color: color, angle: angle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createPlanet(planetIdx: Int, ringIdx: Int, color: UIColor, angle: CGFloat) {
        _planet = SKSpriteNode(imageNamed: "planet\(planetIdx)")
        _planet.position = CGPointZero
        _planet.zPosition = 10
        _planet.zRotation = angle
        _planet.color = color
        _planet.colorBlendFactor = _blend
        addChild(_planet)
        
        if ringIdx < _numRings {
            _top = SKSpriteNode(imageNamed: "ring\(ringIdx)_top")
            _top!.position = CGPointZero
            _top!.zPosition = 11
            _top!.zRotation = angle
            _top!.color = color
            _top!.colorBlendFactor = _ringBlend
            addChild(_top!)
            
            _bot = SKSpriteNode(imageNamed: "ring\(ringIdx)_bottom")
            _bot!.position = CGPointZero
            _bot!.zPosition = 9
            _bot!.zRotation = angle
            _bot!.color = color
            _bot!.colorBlendFactor = _ringBlend
            addChild(_bot!)
        }
    }
    
    func setSize(size: CGSize) {
        _planet.size = size
        _top?.size = size
        _bot?.size = size
    }
}
