//
//  Level.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 10/6/15.
//  Copyright © 2015 iNoyola. All rights reserved.
//

import UIKit

class Level: NSObject {

    var _level = 1
    var _seed = UInt32(time(nil))
    
    var _width = 0
    var _height = 0
    var _startX = 0
    var _startY = 0
    var _grid: [PieceType]! = nil
    var _history: [(x: Int, y: Int)]! = []
    var _teleporters: [(x: Int, y: Int)] = []
    
    
    @inline(__always) func getCode() -> String {
        return "\(_level).\(_seed)"
    }
    
    @inline(__always) func getPiece(x x: Int, y: Int) -> PieceType {
        return _grid[y * _width + x]
    }
    
    @inline(__always) func setPiece(x x: Int, y: Int, type: PieceType) {
        _grid[y * _width + x] = type
    }
    
    func getTeleporterPair(x x: Int, y: Int) -> (x: Int, y: Int) {
        for i in 0...(_teleporters.count - 1) {
            let p0 = _teleporters[i]
            if x == p0.x && y == p0.y {
                if (i % 2) == 0 {
                    return _teleporters[i + 1]
                } else {
                    return _teleporters[i - 1]
                }
            }
        }
        NSLog("ERROR: teleporter match not found")
        return (-1, -1)
    }
    
// -----------------------------------------------------------------------
    
    func generate() {
        srandom(_seed)

        _width = _level / 2 + 3
        _height = _level / 2 + 3
        _grid = [PieceType](count: _width * _height, repeatedValue: .None)
    
        startWithNumPathPieces(getNumPathPieces())
        
        _history = nil
    }
    
    func getNumPathPieces() -> Int {
        if _level < 4 {
            return _level
        }
        return _level + random() % (_level / 2)
    }
    
    func startWithNumPathPieces(num: Int) {
    }
    
// -----------------------------------------------------------------------
    
    func generateTestLevel() {
        _width = 8
        _height = 8
        _grid = [PieceType](count: _width * _height, repeatedValue: .None)
    
        _startX = 0
        _startY = 0
        setPiece(x: 0, y: 3, type: .Block)
        setPiece(x: 1, y: 2, type: .Corner3)
        setPiece(x: 1, y: 0, type: .Corner3)
        setPiece(x: 3, y: 1, type: .Corner2)
        setPiece(x: 3, y: 3, type: .Corner4)
        setPiece(x: 4, y: 3, type: .Corner3)
        setPiece(x: 4, y: 2, type: .Corner2)
        setPiece(x: 2, y: 5, type: .Corner3)
        setPiece(x: 1, y: 5, type: .Corner1)
        setPiece(x: 1, y: 7, type: .Block)
        setPiece(x: 0, y: 6, type: .Corner2)
        setPiece(x: 3, y: 6, type: .Teleporter)
        _teleporters.append((3,6))
        setPiece(x: 0, y: 4, type: .Teleporter)
        _teleporters.append((0,4))
        setPiece(x: 6, y: 4, type: .Block)
        setPiece(x: 5, y: 6, type: .Target)
    }
}
