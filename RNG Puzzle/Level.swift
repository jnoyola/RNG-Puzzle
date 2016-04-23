//
//  Level.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 10/6/15.
//  Copyright © 2015 iNoyola. All rights reserved.
//

import Foundation

class Level: NSObject, LevelProtocol {

    typealias Point = (x: Int, y: Int)

    var _level = 1
    var _seed = UInt32(time(nil)) % 10000
    
    var _width = 0
    var _height = 0
    var _startX = 0
    var _startY = 0
    var _grid: [PieceType]! = nil
    var _teleporters: [Point] = []
    var _stops = Set<PointRecord>()
    
    var _correct: [PointRecord!]? = nil
    
    
    @inline(__always) func getCode() -> String {
        return "\(_level).\(_seed)"
    }
    
    @inline(__always) func getSeedString() -> String {
        return "\(_seed)"
    }
    
    @inline(__always) func getPiece(x x: Int, y: Int) -> PieceType {
        return _grid[y * _width + x]
    }
    
    @inline(__always) func setPiece(x x: Int, y: Int, type: PieceType) {
        if !type.contains(.Stop) && getPiece(x: x, y: y).contains(.Stop) {
            _stops.remove(PointRecord(x: x, y: y))
        }
        _grid[y * _width + x] = type
    }
    
    @inline(__always) func addPiece(x x: Int, y: Int, type: PieceType) {
        var piece = getPiece(x: x, y: y)
        piece.insert(type)
        setPiece(x: x, y: y, type: piece)
    }
    
    @inline(__always) func addStop(x x: Int, y: Int) {
        var piece = getPiece(x: x, y: y)
        piece.insert(.Stop)
        setPiece(x: x, y: y, type: piece)
        _stops.insert(PointRecord(x: x, y: y))
    }
    
    @inline(__always) func addDirectedStop(x x: Int, y: Int, dir: Direction) {
        var piece = getPiece(x: x, y: y)
        piece.insert(.Stop)
        setPiece(x: x, y: y, type: piece)
        _stops.insert(PointRecord(x: x, y: y, dir: dir))
    }
    
    func setUsed(point: Point) {
        let type = getPiece(x: point.x, y: point.y)
        if type.contains(.Used) {
            setPiece(x: point.x, y: point.y, type: type.union(.Used2))
        } else {
            setPiece(x: point.x, y: point.y, type: .Used)
        }
    }
    
    func setUnused(point: Point) {
        let type = getPiece(x: point.x, y: point.y)
        if type.contains(.Used2) {
            setPiece(x: point.x, y: point.y, type: .Used)
        } else {
            setPiece(x: point.x, y: point.y, type: .None)
        }
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
        NSLog("ERROR  (\(_level).\(_seed)): teleporter match for (\(x),\(y)) not found")
        return (-1, -1)
    }
    
// -----------------------------------------------------------------------

    init(level: Int, seed: String?) {
        _level = level
        if seed != nil {
            _seed = UInt32((seed! as NSString).integerValue)
        }
    }
    
    func generate(debug: Bool) -> Bool {
        srandom(getTrueSeed())

        _width = getWidth()
        _height = _width
    
        let numPathPieces = getNumPathPieces()
        _correct = [PointRecord!](count: numPathPieces + 1, repeatedValue: nil)
    
        startWithNumPathPieces(numPathPieces)
        
        createDeadEnds()
        
        // Always do this last, because it doesn't add unplanned stops
        addUselessBlocks(2 * _level)
        
        if debug {
            return debugCheck()
        }
        return true
    }
    
    func getTrueSeed() -> UInt32 {
        // Every third level actually has equal difficulty as the last,
        // just with a different seed
        var trueSeed = _seed % 10000
        if (_level + 1) % 3 == 0 {
            trueSeed = UINT32_MAX - _seed
        }
        
        // Random bug causing infinite loop when creating dead ends
        if _level == 36 && trueSeed == 6190 {
            trueSeed = 10000
        }
        return trueSeed
    }
    
    func getWidth() -> Int {
        return 4 + _level / 3
    }
    
    func getNumPathPieces() -> Int {
        return 1 + (_level - 1) / 3
    }
    
    func startWithNumPathPieces(num: Int) {
        while true {
            _grid = [PieceType](count: _width * _height, repeatedValue: .None)
            _startX = random() % _width
            _startY = random() % _height
            addStop(x: _startX, y: _startY)
            
            let dirs = PieceType.getNextDirections(.Still)
            if nextWithNumPathPieces(num, x: _startX, y: _startY, dirs: dirs, isTruePath: true) {
                break
            }
        }
    }
    
    func nextWithNumPathPieces(num: Int, x: Int, y: Int, var dirs: [Direction], isTruePath: Bool) -> Bool {
        
        if num == 0 && !isTruePath {
        
            // Finish projecting the dead end forward to make sure we didn't create a shortcut
            let unplannedStops = getUnplannedStopsForPlannedStopAt(x: x, y: y, dirs: dirs, visited: Set<PointRecord>())
            if unplannedStops == nil {
                return false
            }
            for point in unplannedStops! {
                addStop(x: point.x, y: point.y)
            }
            
            if dirs.count == 1 {
                let dir = dirs[0]
                
                // Make sure a corner doesn't force the ball through wall
                let nextPos = getAdjPosFrom(x: x, y: y, dir: dir)
                let nextPiece = getPieceSafely(nextPos)
                if nextPiece.isWallFromDir(dir) {
                    return false
                }
                
                // Make sure a wall can't be placed right in front of this corner
                let lastDir = getPiece(x: x, y: y).getNextDirections(getOppDir(dir))[0]
                let lastPos = getAdjPosFrom(x: x, y: y, dir: lastDir)
                let lastPiece = getPieceSafely(lastPos)
                if lastPiece == .None {
                    setPiece(x: lastPos.x, y: lastPos.y, type: .Used)
                }
                if nextPiece == .None {
                    setPiece(x: nextPos.x, y: nextPos.y, type: .Used)
                }
                
                addPiece(x: x, y: y, type: .Stop)
            }
            return true
        }
    
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
            
                    // Add the correct direction to get to each path waypoint
                    if isTruePath {
                        _correct![_correct!.count - num - 1] = PointRecord(x: offset.x, y: offset.y, dir: dir)
                    }
                    
                    // Set path here
                    // We can't use head recursion because the following pieces might
                    // depend on the placement of the current path and piece
                    for var i = 0; i < iOffset; ++i {
                        setUsed(offsets[i])
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
                        if stopOutsideWallShortcuts(.Target, x: offset.x, y: offset.y, dir: dir) {
                            setPiece(x: offset.x, y: offset.y, type: .Target)
                            return true
                        }
                    } else {
                        let weightedArray = WeightedRandomArray(array: getPiecesFromDir(dir))
                        while weightedArray.count() > 0 {
                            // Pick random piece from those remaining
                            let piece = weightedArray.popRandom()
                            
                            // Don't pick too many teleporters
                            if piece == .Teleporter && _teleporters.count >= _width / 4 {
                                continue
                            }
                            
                            var placedNextPiece = false
                            var nextPiecePos = (x: 0, y: 0)
                            var teleporterExit = (x: 0, y: 0)
                            var nextDirs = [Direction]()
                            var alreadyFailed = false
                            
                            if piece.contains(.Block) {
                            
                                // nextDirs is also used for checking for planned .Stop shortcuts
                                nextDirs = PieceType.getNextDirections(dir)
                                
                                // If we're placing a .Block, we have to check if the next space
                                // is empty or if it already contains a wall
                                nextPiecePos = getAdjPosFrom(x: offset.x, y: offset.y, dir: dir)
                                let nextPiece = getPieceSafely(nextPiecePos)
                                if nextPiece == .None {
                                    // The next space is empty. We can place a block there.
                                    addStop(x: offset.x, y: offset.y)
                                    setPiece(x: nextPiecePos.x, y: nextPiecePos.y, type: .Block)
                                    placedNextPiece = true
                                
                                    // Check if this placement created shortcuts connected by new
                                    // unplanned stops
                                    if !stopOutsideWallShortcuts(piece, x: nextPiecePos.x, y: nextPiecePos.y, dir: dir) {
                                        alreadyFailed = true
                                    }
                                } else if iOffset == offsets.count - 1 && nextPiece.isWallFromDir(dir) {
                                    // The next piece is a wall. We can use it to stop.
                                    addStop(x: offset.x, y: offset.y)
                                } else {
                                    // We can't stop here. Mark the .Block as invalid.
                                    continue
                                }
                                
                                // Assuming everything went according to plan, add unplanned stops now
                                if !alreadyFailed {
                                
                                    // To eliminate planned .Stop shortcuts, don't place this planned .Stop
                                    // if this position was already reachable by another .Stop (planned or
                                    // unplanned), or if its placement would create unplanned .Stops that
                                    // create a shortcut. Unplanned stops are added below, after placement
                                    let unplannedStops = getUnplannedStopsForPlannedStopAt(x: offset.x, y: offset.y, dirs: nextDirs, visited: Set<PointRecord>())
                                    if unplannedStops == nil {
                                        alreadyFailed = true
                                    } else {
                                        for point in unplannedStops! {
                                            addStop(x: point.x, y: point.y)
                                        }
                                    }
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
                                        addPiece(x: x, y: y, type: .Stop)
                                        _teleporters.append(teleporterExit)
                                        placedNextPiece = true
                                        nextDirs.append(dir)
                                    
                                        // Make sure we're not in the special case where the player can go through
                                        // the teleporter a different direction and stop on the exit, creating a
                                        // shortcut
                                        if allowsTeleporterShortcuts(offset, exitX: x, exitY: y, dir: dir) {
                                            alreadyFailed = true
                                        }
                                        break
                                    }
                                }
                                
                                // Make sure we found an exit
                                if !placedNextPiece {
                                    continue
                                }
                            } else {
                                
                                // Check if this placement would create shortcuts connected by new
                                // unplanned stops
                                if !stopOutsideWallShortcuts(piece, x: offset.x, y: offset.y, dir: dir) {
                                    continue
                                }
                                
                                // If we're placing a corner, we have nothing else to worry about
                                setPiece(x: offset.x, y: offset.y, type: piece)
                                nextDirs = piece.getNextDirections(dir)
                            }
                            
                            // Move on to the next iteration
                            if !piece.contains(.Teleporter) && !alreadyFailed && nextWithNumPathPieces(num - 1, x: offset.x, y: offset.y, dirs: nextDirs, isTruePath: isTruePath) {
                                
                                // Allow dead ends to continue from a Corner's dead end
                                if !isTruePath && nextDirs.count == 1 {
                                    let nextDir = nextDirs[0]
                                    nextPiecePos = getAdjPosFrom(x: offset.x, y: offset.y, dir: nextDir)
                                    if nextPiecePos.x >= 0 && nextPiecePos.y >= 0 && nextPiecePos.x < _width && nextPiecePos.y < _height {
                                        addDirectedStop(x: nextPiecePos.x, y: nextPiecePos.y, dir: nextDir)
                                    }
                                }
                                
                                return true
                            } else if piece.contains(.Teleporter) && !alreadyFailed && nextWithNumPathPieces(num - 1, x: teleporterExit.x, y: teleporterExit.y, dirs: nextDirs, isTruePath: isTruePath) {
                                
                                // Allow dead ends to continue from a Teleporter's dead end
                                if !isTruePath {
                                    addDirectedStop(x: teleporterExit.x, y: teleporterExit.y, dir: nextDirs[0])
                                }
                                
                                return true
                            } else {
                            
                                setPiece(x: offset.x, y: offset.y, type: .None)
                                
                                if piece.contains(.Teleporter) {
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
                        setUnused(offsets[i])
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
                if offsets.count > 0 && offsets[0].x == x && offsets[0].y == y {
                    break
                }
                offsets.append((x, y))
            } else if type.contains(.Teleporter) {
                let point = getTeleporterPair(x: x, y: y)
                x = point.x
                y = point.y
            } else if !type.contains(.Used) {
                break
            }
        }
        return offsets
    }
    
    func getPiecesFromDir(dir: Direction) -> [PieceType] {
        
        // Half the time, only allow Blocks
        if random() % 2 == 0 {
            return [PieceType](count: 1, repeatedValue: .Block)
        }
        
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
    
    func stopOutsideWallShortcuts(piece: PieceType, x: Int, y: Int, dir: Direction) -> Bool {
        var unplannedStops = [Point]()
        var dirs: [Direction]
        if piece.contains(.Block) || piece.contains(.Target) {
            dirs = [Direction](count: 3, repeatedValue: .Still)
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
        } else {
            dirs = [Direction](count: 2, repeatedValue: .Still)
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
        }

        for wallDir in dirs {
            let point = getAdjPosFrom(x: x, y: y, dir: wallDir)
            var lastPoint: Point? = nil
            if getStopInLineWithPoint(point, dir: wallDir, lastPoint: &lastPoint).contains(.Stop) {
                if piece.contains(.Target) || getPieceSafely(point).contains(.Teleporter) {
                    return false
                } else {
                    // Now that we would be creating an unplanned stop here,
                    // we must first check if it would create a shortcut
                    let shortcutDirs = PieceType.getNextDirections(wallDir)
                    let additionalUnplannedStops = getUnplannedStopsForPlannedStopAt(x: point.x, y: point.y, dirs: shortcutDirs, visited: Set<PointRecord>())
                    if additionalUnplannedStops == nil {
                        return false
                    }
                    unplannedStops.appendContentsOf(additionalUnplannedStops!)
                    
                    unplannedStops.append(point)
                }
            }
        }
        
        // Since we haven't found any shortcuts that would disallow this placement,
        // we can now place all unplanned stops
        for point in unplannedStops {
            addStop(x: point.x, y: point.y)
        }
        
        return true
    }
    
    func getStopInLineWithPoint(var point: Point, dir: Direction, inout lastPoint: Point?) -> PieceType {
        if lastPoint != nil {
            lastPoint = (x: -1, y: -1)
        }
        
        var usedTeleporters = Set<PointRecord>()
        while true {
            let type = getPieceSafely(point)
            
            if type.contains(.Teleporter) {
            
                // Return early if it's a Teleporter that can be stopped on
                if type.contains(.Stop) {
                    return type
                }
            
                let dst = getTeleporterPair(x: point.x, y: point.y)
                
                // If we've gone in a loop, return .Void
                // This may allow players to enter a Teleporter loop from an unplanned Stop
                let pointRecord = PointRecord(x: point.x, y: point.y)
                if !usedTeleporters.contains(pointRecord) {
                    usedTeleporters.insert(pointRecord)
                } else {
                    if lastPoint != nil {
                        lastPoint = (x: -1, y: -1)
                    }
                    return .Void
                }
                
                if lastPoint != nil {
                    lastPoint = (x: dst.x, y: dst.y)
                }
                point = getAdjPosFrom(x: dst.x, y: dst.y, dir: dir)
            } else if type == .Used || type == .None {
                if lastPoint != nil {
                    lastPoint = (x: point.x, y: point.y)
                }
                point = getAdjPosFrom(x: point.x, y: point.y, dir: dir)
            } else {
                // This is triggered for all pieces, .Stop, and .Void
                return type
            }
        }
    }
    
    func getUnplannedStopsForPlannedStopAt(x x: Int, y: Int, dirs: [Direction], var visited: Set<PointRecord>) -> [Point]? {
    
        // Recursively get unplanned stops for the intended planned stop placement
        // If this would create a shortcut, return nil
        
        let pointRecord = PointRecord(x: x, y: y)
        if visited.contains(pointRecord) {
            return nil
        }
        visited.insert(pointRecord)
        
        var coordsForRetroStops = [Point]()
    
        for dir in dirs {
            let point = getAdjPosFrom(x: x, y: y, dir: dir)
            var lastPoint: Point? = (x: -1, y: -1)
            let extendedSpaceType = getStopInLineWithPoint(point, dir: dir, lastPoint: &lastPoint)
            let lastPiece = getPieceSafely(lastPoint!)
            if extendedSpaceType.contains(.Stop) ||
               extendedSpaceType.contains(.Target) ||
               (extendedSpaceType != .Void && lastPiece.contains(.Used)) ||
               lastPiece.contains(.Teleporter) {
                return nil
            } else if !extendedSpaceType.contains(.Void) {
                if lastPoint!.x == -1 {
                    return nil
                } else {
                    let nextDirs = PieceType.getNextDirections(dir)
                    let additionalCoords = getUnplannedStopsForPlannedStopAt(x: lastPoint!.x, y: lastPoint!.y, dirs: nextDirs, visited: visited)
                    if additionalCoords == nil {
                        return nil
                    } else {
                        coordsForRetroStops.appendContentsOf(additionalCoords!)
                    }
                    coordsForRetroStops.append(lastPoint!)
                }
            }
        }
        
        return coordsForRetroStops
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
    
    func allowsTeleporterShortcuts(teleporter: Point, exitX: Int, exitY: Int, dir: Direction) -> Bool {
        let unplannedStops1 = getTeleporterUnplannedStops(teleporter.x, inY: teleporter.y, outX: exitX, outY: exitY, dir: dir)
        if unplannedStops1 == nil {
            return true
        }

        let unplannedStops2 = getTeleporterUnplannedStops(exitX, inY: exitY, outX: teleporter.x, outY: teleporter.y, dir: getOppDir(dir))
        if unplannedStops2 == nil {
            return true
        }
        
        for point in unplannedStops1! {
            addStop(x: point.x, y: point.y)
        }
        for point in unplannedStops2! {
            addStop(x: point.x, y: point.y)
        }
        return false
    }
    
    func getTeleporterUnplannedStops(inX: Int, inY: Int, outX: Int, outY: Int, dir: Direction) -> [Point]? {
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
        
        var unplannedStops = [Point]()
        
        for inDir in dirs {
            let inPos = getAdjPosFrom(x: inX, y: inY, dir: inDir)
            var lastPoint: Point? = nil
            if getStopInLineWithPoint(inPos, dir: inDir, lastPoint: &lastPoint).contains(.Stop) {
                let outDir = getOppDir(inDir)
                let outDirs = [Direction](count: 1, repeatedValue: outDir)
                let additionalUnplannedStops = getUnplannedStopsForPlannedStopAt(x: outX, y: outY, dirs: outDirs, visited: Set<PointRecord>())
                if additionalUnplannedStops == nil {
                    return nil
                } else {
                    unplannedStops.appendContentsOf(additionalUnplannedStops!)
                }
            }
        }
        return unplannedStops
    }
    
    func getOppDir(dir: Direction) -> Direction {
        switch dir {
        case .Up: return .Down
        case .Down: return .Up
        case .Left: return .Right
        case .Right: return .Left
        default: return .Still
        }
    }
    
// -----------------------------------------------------------------------

    func createDeadEnds() {
        var numDeadEnds = 0
        while !_stops.isEmpty {
            let stop = _stops.popFirst()
            
            var dirs: [Direction]!
            if stop!.dir == .Still {
                dirs = PieceType.getNextDirections(.Still)
            } else {
                dirs = [Direction](count: 1, repeatedValue: stop!.dir)
            }
            for dir in dirs {
                let point = getAdjPosFrom(x: stop!.x, y: stop!.y, dir: dir)
                if getPieceSafely(point) == .None {
                    if createDeadEnd(point, dir: dir) {
                        ++numDeadEnds
                        break
                    }
                }
            }
        }
    }
    
    func createDeadEnd(point: Point, dir: Direction) -> Bool {
        let dirs = [Direction](count: 1, repeatedValue: dir)
        if nextWithNumPathPieces(1, x: point.x, y: point.y, dirs: dirs, isTruePath: false) {
            addPiece(x: point.x, y: point.y, type: .Used)
            return true
        }
        return false
    }
    
    func addUselessBlocks(num: Int) {
        for x in 0..._width-1 {
            for y in 0..._height-1 {
            
                if getPiece(x: x, y: y) != .None || random() % 8 == 0 {
                    continue
                }
                
                var success = true
                let dirs = PieceType.getNextDirections(.Still)
                var lastPoint: Point? = nil
                for dir in dirs {
                    if getStopInLineWithPoint((x: x, y: y), dir: dir, lastPoint: &lastPoint).contains(.Stop) {
                        success = false
                        break
                    }
                }
                
                if success {
                    setPiece(x: x, y: y, type: .Block)
                }
            }
        }
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
            _startX = 1
            _startY = 1
            setPiece(x: 7, y: 1, type: .Corner3)
            setPiece(x: 7, y: 0, type: .Target)
        case 10:
            _startX = 100
            _startY = 100
        case 11:
            _startX = 100
            _startY = 100
        default: break
        }
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
    
    func debugCheck() -> Bool {
        let numSolutions = getNumSolutions()
        if numSolutions != 1 {
            NSLog("ERROR: (\(_level).\(_seed)) \(numSolutions) solutions found")
            return false
        }
        
        return true
    }
}
