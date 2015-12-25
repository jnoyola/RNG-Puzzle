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
    static let Used =       PieceType(rawValue: 1 << 0)
    static let Void =       PieceType(rawValue: 1 << 1)
    static let Block =      PieceType(rawValue: 1 << 2)
    static let Corner1 =    PieceType(rawValue: 1 << 3)
    static let Corner2 =    PieceType(rawValue: 1 << 4)
    static let Corner3 =    PieceType(rawValue: 1 << 5)
    static let Corner4 =    PieceType(rawValue: 1 << 6)
    static let Teleporter = PieceType(rawValue: 1 << 7)
    static let Target =     PieceType(rawValue: 1 << 8)
    static let Stop =       PieceType(rawValue: 1 << 9)
}

struct Piece {
    var x: Int
    var y: Int
    var type: PieceType
}
