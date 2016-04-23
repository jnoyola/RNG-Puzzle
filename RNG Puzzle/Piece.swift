//
//  Piece.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 10/8/15.
//  Copyright © 2015 iNoyola. All rights reserved.
//

enum Direction {
    case Still
    case Right
    case Up
    case Left
    case Down
}

struct PieceType: OptionSetType {
    let rawValue: Int
    
    static let None =       PieceType(rawValue: 0)
    static let Used =       PieceType(rawValue: 1 << 0) //   1
    static let Void =       PieceType(rawValue: 1 << 1) //   2
    static let Block =      PieceType(rawValue: 1 << 2) //   4
    static let Corner1 =    PieceType(rawValue: 1 << 3) //   8
    static let Corner2 =    PieceType(rawValue: 1 << 4) //  16
    static let Corner3 =    PieceType(rawValue: 1 << 5) //  32
    static let Corner4 =    PieceType(rawValue: 1 << 6) //  64
    static let Teleporter = PieceType(rawValue: 1 << 7) // 128
    static let Target =     PieceType(rawValue: 1 << 8) // 256
    static let Stop =       PieceType(rawValue: 1 << 9) // 512
    static let Used2 =      PieceType(rawValue: 1 << 10)// 1024
    
    func isWallFromDir(dir: Direction) -> Bool {
        if contains(.Block) ||
           (contains(.Corner1) && (dir == .Right || dir == .Up))   ||
           (contains(.Corner2) && (dir == .Up    || dir == .Left)) ||
           (contains(.Corner3) && (dir == .Left  || dir == .Down)) ||
           (contains(.Corner4) && (dir == .Down  || dir == .Right)) {
            return true
        }
        return false
    }
    
    static func getNextDirections(dir: Direction) -> [Direction] {
        switch (dir) {
        case .Up: fallthrough
        case .Down: return [Direction.Left, Direction.Right]
        case .Left: fallthrough
        case .Right: return [Direction.Up, Direction.Down]
        default: return [Direction.Right, Direction.Up, Direction.Left, Direction.Down]
        }
    }
    
    func getNextDirections(dir: Direction) -> [Direction] {
        if contains(.Corner1) {
            if dir == .Left {
                return [Direction.Up]
            } else if dir == .Down {
                return [Direction.Right]
            }
        } else if contains(.Corner2) {
            if dir == .Down {
                return [Direction.Left]
            } else if dir == .Right {
                return [Direction.Up]
            }
        } else if contains(.Corner3) {
            if dir == .Right {
                return [Direction.Down]
            } else if dir == .Up {
                return [Direction.Left]
            }
        } else if contains(.Corner4) {
            if dir == .Up {
                return [Direction.Right]
            } else if dir == .Left {
                return [Direction.Down]
            }
        }
        return [Direction.Still]
    }
}

struct Piece {
    var x: Int
    var y: Int
    var type: PieceType
}
