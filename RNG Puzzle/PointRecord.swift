//
//  Point.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 3/19/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

class PointRecord: Hashable {
    var x: Int
    var y: Int
    var dir: Direction = .Still
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    init(x: Int, y: Int, dir: Direction) {
        self.x = x
        self.y = y
        self.dir = dir
    }
    
    var hashValue: Int {
        get {
            return "\(x),\(y),\(dir)".hashValue
        }
    }
}

func ==(lhs: PointRecord, rhs: PointRecord) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.dir == rhs.dir
}
