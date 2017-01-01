//
//  WeightedRandomArray.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 1/5/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import Foundation
import GameKit

class WeightedRandomArray: NSObject {
    var _array: [PieceType]! = nil
    var _totalWeight: UInt32 = 0
    var _rng: GKRandomSource! = nil
    
    init(array: [PieceType], rng: GKRandomSource) {
        super.init()
        _rng = rng
        _array = array
        for piece in array {
            _totalWeight += getWeight(piece: piece)
        }
    }
    
    func popRandom() -> PieceType {
        let r = UInt32(_rng.nextInt(upperBound: Int(_totalWeight)))
        var iPiece = 0
        var cumWeight: UInt32 = 0
        while true {
            cumWeight += getWeight(piece: _array[iPiece])
            if cumWeight > r {
                break
            }
            iPiece += 1
        }
        let piece = _array[iPiece]
        _array.remove(at: iPiece)
        _totalWeight -= getWeight(piece: piece)
        return piece
    }

    func count() -> Int {
        return _array.count
    }
    
    func getWeight(piece: PieceType) -> UInt32 {
        if piece.contains(.Block) {
            return 30
        } else if piece.contains(.Corner1) ||
                  piece.contains(.Corner2) ||
                  piece.contains(.Corner3) ||
                  piece.contains(.Corner4) {
            return 5
        } else if piece.contains(.Teleporter) {
            return 2
        } else if piece.contains(.Target) {
            return 1
        }
        return 0
    }
}
