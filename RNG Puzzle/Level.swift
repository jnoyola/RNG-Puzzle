//
//  Level.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 10/6/15.
//  Copyright © 2015 iNoyola. All rights reserved.
//

import UIKit

class Level: NSObject {

    typealias Point = (x: Int, y: Int)

    var _level = 1
    var _seed = UInt32(time(nil))
    
    var _width = 0
    var _height = 0
    var _startX = 0
    var _startY = 0
    var _grid: [PieceType]! = nil
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
    
    func getPieceSafely(point: Point) -> PieceType {
        if point.x >= 0 && point.y >= 0 && point.x < _width && point.y < _height {
            return getPiece(x: point.x, y: point.y)
        }
        return .Void
    }
    
    func getTeleporterPair(x x: Int, y: Int) -> Point {
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

    override init() {
        super.init()
    }
    
    func generate() {
        srandom(_seed)

        _width = _level / 2 + 3
        _height = _level / 2 + 3
        _grid = [PieceType](count: _width * _height, repeatedValue: .None)
    
        startWithNumPathPieces(getNumPathPieces())
    }
    
    func getNumPathPieces() -> Int {
        if _level < 4 {
            return _level
        }
        return _level + random() % (_level / 2)
    }
    
    func startWithNumPathPieces(num: Int) {
        _startX = random() % _width
        _startY = random() % _height
        setPiece(x: _startX, y: _startY, type: .Stop)
        
        let dirs = getNextDirections(.Still)
        nextWithNumPathPieces(num, x: _startX, y: _startY, dirs: dirs)
    }
    
    func nextWithNumPathPieces(num: Int, x: Int, y: Int, var dirs: [Direction]) -> Bool {
        while dirs.count > 0 {
            // Pick random direction from those remaining
            let iDir = random() % dirs.count
            let dir = dirs[iDir]
            
            // Get offsets
            let offsets = getOffsetsFrom(x: x, y: y, dir: dir)
            if offsets.count > 0 {
                // Make a seperate array for indices of the offsets array.
                // This way we won't have to remove elements of the offsets array,
                // which is good because we'll use those elements to know where we need
                // to set the path type to .Used
                var offsetIndices = [Int](0...(offsets.count - 1))
                while offsetIndices.count > 0 {
                    // Pick random offset from those remaining
                    let iOffsetIndex = random() % offsetIndices.count
                    let iOffset = offsetIndices[iOffsetIndex]
                    let offset = offsets[iOffset]
                    
                    // Set path here
                    // We can't use head recursion because the following pieces might
                    // depend on the placement of the current path and piece
                    for var i = 0; i < iOffset; ++i {
                        let pathOffset = offsets[i]
                        setPiece(x: pathOffset.x, y: pathOffset.y, type: .Used)
                    }
                
                    // There are 4 options here:
                    //   1) if (num == 0)
                    //      Place the Target. We're done
                    //   2) if (nextPiece == NONE)
                    //      We can stop or bounce, and we must place a piece for both
                    //   3) else if (iOffset == [offsets count])
                    //      If the blockingPiece is a wall from this direction, we can stop
                    //      or bounce, but we don't place a piece if we stop
                    //   4) else
                    //      We must bounce
                    
                    if num == 0 {
                        if stopShortcutsForPiece(.Target, x: offset.x, y: offset.y, dir: dir) {
                            setPiece(x: offset.x, y: offset.y, type: .Target)
                            return true
                        }
                    } else {
                        let weightedArray = WeightedRandomArray(array: getPiecesFromDir(dir))
                        while weightedArray.count() > 0 {
                            // Pick random piece from those remaining
                            let piece = weightedArray.popRandom()
                            var placedNextPiece = false
                            var nextPiecePos = (x: 0, y: 0)
                            var teleporterExit = (x: 0, y: 0)
                            var nextDirs = [Direction]()
                            
                            if piece.contains(.Block) {
                                // nextDirs is also used for checking for planned .Stop shortcuts
                                nextDirs = getNextDirections(dir)
                                
                                // To eliminate planned .Stop shortcuts, don't place this planned .Stop
                                // if this position was already reachable by another .Stop (planned or
                                // unplanned)
                                if arePlannedStopShortcutsAt(x: offset.x, y: offset.y, dirs: nextDirs) {
                                    continue
                                }
                                
                                // If we're placing a .Block, we have to check if the next space
                                // is empty or if it already contains a wall
                                nextPiecePos = getAdjPosFrom(x: offset.x, y: offset.y, dir: dir)
                                let nextPiece = getPieceSafely(nextPiecePos)
                                if nextPiece == .None {
                                    // The next space is empty. We can place a block there.
                                    setPiece(x: offset.x, y: offset.y, type: .Stop)
                                    setPiece(x: nextPiecePos.x, y: nextPiecePos.y, type: .Block)
                                    placedNextPiece = true
                                    stopShortcutsForPiece(piece, x: nextPiecePos.x, y: nextPiecePos.y, dir: dir)
                                } else if iOffset == offsets.count - 1 && isWallFromDir(dir, pieceType: nextPiece) {
                                    // The next piece is a wall. We can use it to stop.
                                    setPiece(x: offset.x, y: offset.y, type: .Stop)
                                } else {
                                    // We can't stop here. Mark the .Block as invalid.
                                    continue
                                }
                            } else if piece.contains(.Teleporter) {
                                // Make 10 attempts at finding a valid exit location
                                // The exit point must be an empty space with at least one open adjacent space
                                for _ in 0...9 {
                                    let x = random() % _width
                                    let y = random() % _height
                                    // Make sure we're not putting the exit at the same location as the entrance
                                    // We haven't marked the grid yet, so isValidTeleporterExit can't catch this
                                    if x == offset.x && y == offset.y {
                                        continue
                                    }
                                    if isValidTeleporterExitAt(x: x, y: y) {
                                        teleporterExit = (x: x, y: y)
                                        setPiece(x: offset.x, y: offset.y, type: .Teleporter)
                                        _teleporters.append(offset)
                                        setPiece(x: x, y: y, type: .Teleporter)
                                        _teleporters.append(teleporterExit)
                                        placedNextPiece = true
                                        nextDirs.append(dir)
                                        break
                                    }
                                }
                                
                                // Make sure we found an exit
                                if !placedNextPiece {
                                    continue
                                }
                            } else {
                                // If we're placing a corner, we have nothing to worry about
                                setPiece(x: offset.x, y: offset.y, type: piece)
                                stopShortcutsForPiece(piece, x: offset.x, y: offset.y, dir: dir)
                                nextDirs = getNextDirectionsForCorner(piece, dir: dir)
                            }
                            
                            // Move on to the next iteration
                            if !piece.contains(.Teleporter) && nextWithNumPathPieces(num - 1, x: offset.x, y: offset.y, dirs: nextDirs) {
                                return true
                            } else if piece.contains(.Teleporter) && nextWithNumPathPieces(num - 1, x: teleporterExit.x, y: teleporterExit.y, dirs: nextDirs) {
                                return true
                            } else {
                                // This is the undo section for removing this piece and placing a different one
                                // at the same offset. We only need to undo if we placed a block in the next space
                                // though. The current space will be overwritten by the next piece, and if we move
                                // to another offset then it'll be undone along with the path.
                                
                                if piece.contains(.Teleporter) {
                                    // We do actually need to erase this teleporter, because if a .Block is selected
                                    // next, then instead of being overwritten, this teleporter will be changed to a
                                    // .Teleporter & .Stop
                                    setPiece(x: offset.x, y: offset.y, type: .None)
                                    setPiece(x: teleporterExit.x, y: teleporterExit.y, type: .None)
                                    _teleporters.removeLast()
                                    _teleporters.removeLast()
                                } else if placedNextPiece {
                                    setPiece(x: nextPiecePos.x, y: nextPiecePos.y, type: .None)
                                }
                            }
                        }
                    }
                    
                    // This offset wasn't valid.
                    // Undo the path and piece placement, and remove the offset index.
                    for i in 0...iOffset {
                        let pathOffset = offsets[i]
                        setPiece(x: pathOffset.x, y: pathOffset.y, type: .None)
                    }
                    offsetIndices.removeAtIndex(iOffsetIndex)
                }
            }
            
            // This direction wasn't valid. Remove it.
            dirs.removeAtIndex(iDir)
        }
    
        // No valid directions. Time to undo?
        return false
    }
    
    func getNextDirections(lastDir: Direction) -> [Direction] {
        switch (lastDir) {
        case .Up: fallthrough
        case .Down: return [Direction.Left, Direction.Right]
        case .Left: fallthrough
        case .Right: return [Direction.Up, Direction.Down]
        default: return [Direction.Right, Direction.Up, Direction.Left, Direction.Down]
        }
    }
    
    func getNextDirectionsForCorner(piece: PieceType, dir: Direction) -> [Direction] {
        var dirs = [Direction](count: 1, repeatedValue: .Still)
        if piece.contains(.Corner1) {
            if dir == .Left {
                dirs[0] = .Up
            } else if dir == .Down {
                dirs[0] = .Right
            }
        } else if piece.contains(.Corner2) {
            if dir == .Down {
                dirs[0] = .Left
            } else if dir == .Right {
                dirs[0] = .Up
            }
        } else if piece.contains(.Corner3) {
            if dir == .Right {
                dirs[0] = .Down
            } else if dir == .Up {
                dirs[0] = .Left
            }
        } else if piece.contains(.Corner4) {
            if dir == .Up {
                dirs[0] = .Right
            } else if dir == .Left {
                dirs[0] = .Down
            }
        }
        return dirs
    }
    
    func getOffsetsFrom(var x x: Int, var y: Int, dir: Direction) -> [Point] {
        var offsets = [Point]()
        while true {
            switch dir {
                case .Right: ++x
                case .Up:    ++y
                case .Left:  --x
                case .Down:  --y
                default: break
            }
            
            // if type is .None, add it to array
            // if type is not .None or .Used, break
            let type = getPieceSafely((x: x, y: y))
            if type == .None {
                offsets.append((x, y))
            } else if type != .Used {
                break
            }
        }
        return offsets
    }
    
    func getPiecesFromDir(dir: Direction) -> [PieceType] {
        var pieces = [PieceType](count: 4, repeatedValue: .Block)
        pieces[1] = .Teleporter
        switch dir {
            case .Left:
                pieces[2] = .Corner4
                pieces[3] = .Corner1
            case .Down:
                pieces[2] = .Corner1
                pieces[3] = .Corner2
            case .Right:
                pieces[2] = .Corner2
                pieces[3] = .Corner3
            case .Up:
                pieces[2] = .Corner3
                pieces[3] = .Corner4
            default: break
        }
        return pieces
    }
    
    func getAdjPosFrom(var x x: Int, var y: Int, dir: Direction) -> Point {
        switch dir {
            case .Right: ++x
            case .Up:    ++y
            case .Left:  --x
            case .Down:  --y
            default: break
        }
        return (x: x, y: y)
    }
    
    func stopShortcutsForPiece(piece: PieceType, x: Int, y: Int, dir: Direction) -> Bool {
        if piece.contains(.Block) || piece.contains(.Target) {
            var dirs = [Direction](count: 3, repeatedValue: .Still)
            // Check the 3 directions not including the one we came from
            switch dir {
                case .Right:
                    dirs[0] = .Right
                    dirs[1] = .Up
                    dirs[2] = .Down
                case .Up:
                    dirs[0] = .Right
                    dirs[1] = .Up
                    dirs[2] = .Left
                case .Left:
                    dirs[0] = .Up
                    dirs[1] = .Left
                    dirs[2] = .Down
                case .Down:
                    dirs[0] = .Right
                    dirs[1] = .Left
                    dirs[2] = .Down
                default: break
            }
            for i in 0...2 {
                let point = getAdjPosFrom(x: x, y: y, dir: dirs[i])
                var lastPoint: Point? = nil
                if getStopInLineWithPoint(point, dir: dirs[i], lastPoint: &lastPoint).contains(.Stop) {
                    if piece.contains(.Target) {
                        return false
                    } else {
                        setStopAt(x: point.x, y: point.y)
                    }
                }
            }
        } else {
            var dirs = [Direction](count: 2, repeatedValue: .Still)
            // Check the 2 directions extending from walls
            if piece.contains(.Corner1) {
                dirs[0] = .Left
                dirs[1] = .Down
            } else if piece.contains(.Corner2) {
                dirs[0] = .Right
                dirs[1] = .Down
            } else if piece.contains(.Corner3) {
                dirs[0] = .Right
                dirs[1] = .Up
            } else if piece.contains(.Corner4) {
                dirs[0] = .Up
                dirs[1] = .Left
            }
            for i in 0...1 {
                let point = getAdjPosFrom(x: x, y: y, dir: dirs[i])
                var lastPoint: Point? = nil
                if getStopInLineWithPoint(point, dir: dirs[i], lastPoint: &lastPoint).contains(.Stop) {
                    setStopAt(x: point.x, y: point.y)
                }
            }
        }
        return true
    }
    
    func getStopInLineWithPoint(var point: Point, dir: Direction, inout lastPoint: Point?) -> PieceType {
        if lastPoint != nil {
            lastPoint = (x: -1, y: -1)
        }
        
        while true {
            let type = getPieceSafely(point)
            if type.contains(.Teleporter) {
                if lastPoint != nil {
                    lastPoint = (x: point.x, y: point.y)
                }
                point = getTeleporterPair(x: point.x, y: point.y)
                point = getAdjPosFrom(x: point.x, y: point.y, dir: dir)
            } else if type.contains(.Used) || type == .None {
                point = getAdjPosFrom(x: point.x, y: point.y, dir: dir)
            } else {
                // This is triggered for all pieces, .Stop, and .Void
                return type
            }
        }
    }
    
    func isWallFromDir(dir: Direction, pieceType type: PieceType) -> Bool {
        if type.contains(.Block) ||
           (type.contains(.Corner1) && (dir == .Right || dir == .Up))   ||
           (type.contains(.Corner2) && (dir == .Up    || dir == .Left)) ||
           (type.contains(.Corner3) && (dir == .Left  || dir == .Down)) ||
           (type.contains(.Corner4) && (dir == .Down  || dir == .Right)) {
            return true
        }
        return false
    }
    
    func setStopAt(x x: Int, y: Int) {
        var piece = getPiece(x: x, y: y)
        piece.insert(.Stop)
        setPiece(x: x, y: y, type: piece)
    }
    
    func arePlannedStopShortcutsAt(x x: Int, y: Int, dirs: [Direction]) -> Bool {
        var coordsForRetroStops = [Point]()
        for i in 0...(dirs.count - 1) {
            let dir = dirs[i]
            let point = getAdjPosFrom(x: x, y: y, dir: dir)
            var lastPoint: Point? = (x: -1, y: -1)
            let extendedSpaceType = getStopInLineWithPoint(point, dir: dir, lastPoint: &lastPoint)
            if extendedSpaceType.contains(.Stop) {
                return true
            } else if !extendedSpaceType.contains(.Void) {
                if lastPoint!.x != -1 {
                    coordsForRetroStops.append((x: lastPoint!.x, y: lastPoint!.y))
                }
            }
        }
        
        // This is where we retroactively add unplanned .Stops if any eligible coords were found
        for coord in coordsForRetroStops {
            setStopAt(x: coord.x, y: coord.y)
        }
        return false
    }

    func isValidTeleporterExitAt(x x: Int, y: Int) -> Bool {
        if getPiece(x: x, y: y) != .None {
            return false
        }
        
        var piece = getPieceSafely((x: x - 1, y: y))
        if piece.contains(.Used) || piece == .None {
            return true
        }
        
        piece = getPieceSafely((x: x + 1, y: y))
        if piece.contains(.Used) || piece == .None {
            return true
        }
        
        piece = getPieceSafely((x: x, y: y - 1))
        if piece.contains(.Used) || piece == .None {
            return true
        }
        
        piece = getPieceSafely((x: x, y: y + 1))
        if piece.contains(.Used) || piece == .None {
            return true
        }
        
        return false
    }
    
// -----------------------------------------------------------------------

    init(instruction: Int) {
        super.init()
    
        _width = 8
        _height = 3
        _grid = [PieceType](count: _width * _height, repeatedValue: .None)
        
        switch (instruction) {
        case 1:
            _startX = 1
            _startY = 1
            setPiece(x: 6, y: 1, type: .Target)
        case 2:
            _startX = 1
            _startY = 1
        case 3:
            _startX = 1
            _startY = 1
        case 4:
            _startX = 4
            _startY = 2
            setPiece(x: 7, y: 2, type: .Block)
            setPiece(x: 6, y: 0, type: .Corner2)
            setPiece(x: 2, y: 0, type: .Corner3)
        case 5:
            _startX = 1
            _startY = 2
            setPiece(x: 5, y: 2, type: .Teleporter)
            _teleporters.append((5,2))
            setPiece(x: 2, y: 1, type: .Teleporter)
            _teleporters.append((2,1))
            break;
        case 6:
            _startX = 1
            _startY = 2
            setPiece(x: 6, y: 1, type: .Block)
        case 7:
            _startX = 1
            _startY = 1
            setPiece(x: 6, y: 1, type: .Block)
        case 8:
            _startX = 1
            _startY = 1
            setPiece(x: 3, y: 1, type: .Corner1)
            setPiece(x: 2, y: 0, type: .Corner2)
            setPiece(x: 0, y: 0, type: .Corner1)
            setPiece(x: 0, y: 2, type: .Corner4)
            setPiece(x: 4, y: 2, type: .Block)
            setPiece(x: 4, y: 1, type: .Corner3)
            setPiece(x: 4, y: 0, type: .Teleporter)
            _teleporters.append((4,0))
            setPiece(x: 7, y: 2, type: .Teleporter)
            _teleporters.append((7,2))
            setPiece(x: 7, y: 0, type: .Target)
        case 9:
            _startX = 100
            _startY = 100
        case 10:
            _startX = 100
            _startY = 100
        default: break
        }
    }
    
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
