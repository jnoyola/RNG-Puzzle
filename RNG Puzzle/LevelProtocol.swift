//
//  LevelProtocol.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 3/26/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

protocol LevelProtocol {

    var _level: Int { get }
    var _width: Int { get }
    var _height: Int { get }
    var _startX: Int { get }
    var _startY: Int { get }
    var _correct: [PointRecord?]? { get }
    
    func getCode() -> String
    func getSeedString() -> String
    
    func generate(debug: Bool) -> Bool
    
    func getPiece(x: Int, y: Int) -> PieceType
    func getPieceSafely(point: (x: Int, y: Int)) -> PieceType
    
    func getTeleporterPair(x: Int, y: Int) -> (x: Int, y: Int)
}

extension LevelProtocol {
    
    typealias Point = (x: Int, y: Int)
    
    static func getWidthForLevel(_ level: Int) -> Int {
        return 4 + level / 4
    }
    
    static func getLevelRangeForWidth(_ width: Int) -> (min: Int, max: Int) {
        let min = (width - 4) * 4
        let max = min + 3
        return (min: min, max: max)
    }
    
    func getAdjPosFrom(x: Int, y: Int, dir: Direction) -> Point {
        switch dir {
            case .Right: return (x: x + 1, y: y)
            case .Up:    return (x: x, y: y + 1)
            case .Left:  return (x: x - 1, y: y)
            case .Down:  return (x: x, y: y - 1)
            default:     return (x: x, y: y)
        }
    }
    
    func getNumSolutions() -> Int {
        return getNumSolutions(x: _startX, y: _startY, dir: .Still, visited: Set<PointRecord>())
    }
    
    func getNumSolutions(x: Int, y: Int, dir: Direction, visited: Set<PointRecord>) -> Int {
        var x = x
        var y = y
        var dir = dir
        var visited = visited
    
        while true {
            let piece = getPieceSafely(point: (x: x, y: y))
            if piece.contains(.Target) {
                return 1
            }
            if piece.contains(.Void) || piece.isWallFromDir(dir) {
                return 0
            }
            
            var dirs = [Direction](repeating: dir, count: 1)
            if (dir == .Still) {
                dirs = PieceType.getNextDirections(.Still)
            }
            if piece.contains(.Corner1) ||
               piece.contains(.Corner2) ||
               piece.contains(.Corner3) ||
               piece.contains(.Corner4) {
                dirs = piece.getNextDirections(dir)
            } else {
                if piece.contains(.Teleporter) {
                    let point = getTeleporterPair(x: x, y: y)
                    if (point.x == -1) {
                        return 1000
                    }
                    
                    let curPoint = PointRecord(x: x, y: y, dir: dir)
                    if visited.contains(curPoint) {
                        return 0
                    } else {
                        visited.insert(curPoint)
                    }
                    
                    x = point.x
                    y = point.y
                }
                
                let nextPoint = getAdjPosFrom(x: x, y: y, dir: dir)
                let nextPiece = getPieceSafely(point: nextPoint)
                if nextPiece.isWallFromDir(dir) {
                    dirs = PieceType.getNextDirections(dir)
                }
            }
            
            if dirs.count == 1 {
                dir = dirs[0]
                let point = getAdjPosFrom(x: x, y: y, dir: dir)
                x = point.x
                y = point.y
            } else {
                let curPoint = PointRecord(x: x, y: y)
                if visited.contains(curPoint) {
                    return 0
                } else {
                    visited.insert(curPoint)
                }
                
                var numSolutions = 0
                for nextDir in dirs {
                    let point = getAdjPosFrom(x: x, y: y, dir: nextDir)
                    let newVisited = visited.duplicate()
                    numSolutions += getNumSolutions(x: point.x, y: point.y, dir: nextDir, visited: newVisited)
                }
                return numSolutions
            }
        }
    }
}
