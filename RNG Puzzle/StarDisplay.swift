//
//  StarDisplay.swift
//  Astro Maze
//
//  Created by Jonathan Noyola on 7/25/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import SpriteKit
import AVFoundation

class StarDisplay: SKNode {

    var _scene: SKScene! = nil
    var _oldScore = 0
    var _newScore = 1
    var _stars = [Star]()
    
    var _target: CGPoint? = nil
    var _hasFired = false
    
    init(scene: SKScene, oldScore: Int, newScore: Int) {
        super.init()
    
        _scene = scene
        _oldScore = oldScore
        _newScore = newScore
        
        for i in 1...3 {
            _stars.append(createStar(i))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createStar(_ idx: Int) -> Star {
        var star: Star! = nil
        if idx <= _newScore {
            if idx <= _oldScore {
                star = Star(type: .Filled, scene: _scene)
            } else {
                star = Star(type: .Glowing, scene: _scene)
            }
        } else {
            star = Star(type: .Empty, scene: _scene)
        }
        addChild(star)
        return star
    }
    
    func setSize(_ size: CGFloat) {
        let offset: CGFloat = 1
        for i in 0...2 {
            let x = CGFloat(i - 1) * offset * size
            _stars[i].position.x = x
            _stars[i].setSize(size)
        }
    }
    
    func explodeTo(_ dest: CGPoint, completion: @escaping (_ numStars: Int) -> Void) {
        if _hasFired {
            return
        }
        _hasFired = true
        
        if _oldScore < _newScore {
            for i in self._oldScore ..< self._newScore {
                let delay = 0.15 + 0.15 * Double(i - self._oldScore)
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    AudioServicesPlaySystemSound(1306)
                    if i == self._oldScore {
                        self._stars[i].explodeTo(dest: dest, completion: {
                            completion(self._newScore - self._oldScore)
                        })
                    } else {
                        self._stars[i].explodeTo(dest: dest)
                    }
                }
            }
        }
    }
}
