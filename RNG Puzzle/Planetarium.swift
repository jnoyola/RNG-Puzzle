//
//  Planetarium.swift
//  Astro Maze
//
//  Created by Jonathan Noyola on 7/24/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import SpriteKit

class Planetarium: SKNode {

    var _level = 0
    var _maxLevel = 0
    var _showStars = false
    var _showTaunt = false
    var _planets = [PlanetDisplay]()
    
    var _offset: CGFloat = 0
    var _planetOffset: CGFloat = 0
    
    var _markersHidden = false

    init(showStars: Bool = true, showTaunt: Bool = true) {
        super.init()
        
        _showStars = showStars
        _showTaunt = showTaunt
        
        refreshPlanets(size: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func getMaxPlanet() -> Int {
        var maxPlanet = (_maxLevel - 1) / 100
        maxPlanet *= 10
        maxPlanet += 9
        return maxPlanet
    }
    
    func refreshPlanets(size: CGSize?) {
        // Add new planets according to maxLevel
        // Refresh old planets to updates scores
        // keep position
        _maxLevel = Storage.loadMaxLevel()
        
        if size != nil {
            for planet in _planets {
                planet.refresh(size: size!)
            }
        }
        
        let maxPlanet = getMaxPlanet()
        if maxPlanet > _planets.count {
            for i in _planets.count ... maxPlanet {
                let planet = PlanetDisplay(baseLevel: i * 10, showStars: _showStars, showLevels: true, showTaunt: _showTaunt)
                addChild(planet)
                _planets.append(planet)
                
                if size != nil {
                    planet.refreshLayout(size: size!)
                }
            }
        }
        
        if size != nil {
            refreshLayout(size: size!)
        }
    }
    
    func hideMarkers(_ shouldHide: Bool, speed: CGFloat) {
        _markersHidden = shouldHide
        
        var duration = 0.0
        if speed > 0 {
            duration = 3 / Double(speed)
        }
    
        for planet in _planets {
            planet.hideLevelMarkers(shouldHide, duration: duration)
        }
    }
    
    func selectLevel(_ level: Int, animated: Bool = true) {
        if level > 0 {
            _level = level
            selectPlanet((level - 1) / 10, animated: animated)
        } else {
            // Select planet by negative base level
            selectPlanet(-level / 10, animated: animated)
        }
    }
    
    func selectPlanet(_ idx: Int, animated: Bool) {
        let planet = _planets[idx]
        let x = _offset - planet.position.x
        
        if animated {
            let duration = abs(Double(x - position.x)) * 0.0005
            run(SKAction.moveTo(x: x, duration: duration))
        } else {
            position.x = x
        }
    }
    
    func tap(_ p: CGPoint) -> Int? {
        var planetIdx = Int((p.x - position.x + _planetOffset / 2) / _planetOffset)
        planetIdx = max(planetIdx, 0)
        planetIdx = min(planetIdx, _planets.count - 1)
        let x = p.x - position.x - _planets[planetIdx].position.x
        let y = p.y - position.y
    
        return _planets[planetIdx].tap(x: x, y: y)
    }
    
    func hold(_ p: CGPoint) -> Bool {
        let planetIdx = Int((p.x - position.x + _planetOffset / 2) / _planetOffset)
        let x = p.x - position.x - _planets[planetIdx].position.x
        let y = p.y - position.y
        
        if _planets[planetIdx].hold(x: x, y: y) {
            selectPlanet(planetIdx, animated: true)
            return true
        }
        return false
    }
    
    func hideSample() {
        for planet in _planets {
            planet.hideSample()
        }
    }
    
    func translate(dx: CGFloat) -> CGFloat {
        var newX = position.x + dx
        var actualTranslation = newX - position.x
        
        if _offset < newX {
            newX = _offset
            actualTranslation = 0
        } else if _offset - _planets.last!.position.x > newX {
            newX = _offset - _planets.last!.position.x
            actualTranslation = 0
        }
        
        position.x = newX
        return actualTranslation
    }

    func refreshLayout(size: CGSize) {
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        let oldOffset = _offset
        _offset = w / 2
        position.x += (_offset - oldOffset)
        
        _planetOffset = s
        for i in 0..<_planets.count {
            let x = _planetOffset * CGFloat(i)
            _planets[i].position = CGPoint(x: x, y: 0)
            _planets[i].refreshLayout(size: size)
        }
        
        if _level == 0 {
            selectLevel(_maxLevel, animated: false)
        }
    }
}
