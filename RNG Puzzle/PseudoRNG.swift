//
//  PseudoRNG.swift
//  Astro Maze
//
//  Created by Jonathan Noyola on 1/7/17.
//  Copyright © 2017 iNoyola. All rights reserved.
//

// http://www.excamera.com/sphinx/article-xorshift.html
class PseudoRNG {

    var _seed: UInt32 = 0

    init(seed: UInt32) {
        if seed == 0 {
            _seed = UInt32.max
        } else {
            _seed = seed
        }
    }
    
    func next(max: UInt32) -> UInt32 {
        _seed ^= _seed << 13
        _seed ^= _seed >> 17
        _seed ^= _seed << 5
        return _seed % max
    }
    
    func next(max: Int) -> Int {
        return Int(next(max: UInt32(max)))
    }
}
