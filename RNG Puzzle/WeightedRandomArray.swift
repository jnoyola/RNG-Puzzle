//
//  WeightedRandomArray.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 1/5/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import Foundation

class WeightedRandomArray: NSObject {
    var _array: [PieceType]! = nil
    var _totalWeight = 0
    
    init(array: [PieceType]) {
        super.init()
        _array = array
        for piece in array {
            _totalWeight += getWeight(piece)
        }
    }
    
    func popRandom() -> PieceType {
        let r = random() % _totalWeight
        var iPiece = 0
        var cumWeight = 0
        while true {
            cumWeight += getWeight(_array[iPiece])
            if cumWeight > r {
                break
            }
            ++iPiece
        }
        let piece = _array[iPiece]
        _array.removeAtIndex(iPiece)
        _totalWeight -= getWeight(piece)
        return piece
    }

    func count() -> Int {
        return _array.count
    }
    
    func getWeight(piece: PieceType) -> Int {
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
