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
    
    enum LevelError: Error {
        case timeout
        case multipleSolutions
    }

    var _level = 1
    var _seed = UInt32(UInt64(Date.timeIntervalSinceReferenceDate * 10000) % 10000)
    var _displaySeed: UInt32 = 0
    var _isRandom = true
    var _rng: PseudoRNG! = nil
    
    var _width = 0
    var _height = 0
    var _startX = 0
    var _startY = 0
    var _grid: [PieceType]! = nil
    var _teleporters: [Point] = []
    var _stops = [PointRecord]()
    
    var _correct: [PointRecord?]? = nil
    
    var _generationStartTime: Date! = nil
    
    @inline(__always) func getCode() -> String {
        return "\(_level).\(getSeedString())"
    }
    
    @inline(__always) func getSeedString() -> String {
        return "\(_displaySeed)"
    }
    
    @inline(__always) func getPiece(x: Int, y: Int) -> PieceType {
        return _grid[y * _width + x]
    }
    
    @inline(__always) func setPiece(x: Int, y: Int, type: PieceType) {
        if !type.contains(.Stop) && getPiece(x: x, y: y).contains(.Stop) {
            PointRecord(x: x, y: y).remove(from: &_stops)
        }
        _grid[y * _width + x] = type
    }
    
    @inline(__always) func addPiece(x: Int, y: Int, type: PieceType) {
        var piece = getPiece(x: x, y: y)
        piece.insert(type)
        setPiece(x: x, y: y, type: piece)
    }
    
    @inline(__always) func addStop(x: Int, y: Int) {
        var piece = getPiece(x: x, y: y)
        piece.insert(.Stop)
        setPiece(x: x, y: y, type: piece)
        _stops.append(PointRecord(x: x, y: y))
    }
    
    @inline(__always) func addDirectedStop(x: Int, y: Int, dir: Direction) {
        var piece = getPiece(x: x, y: y)
        piece.insert(.Stop)
        setPiece(x: x, y: y, type: piece)
        _stops.append(PointRecord(x: x, y: y, dir: dir))
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
    
    func getTeleporterPair(x: Int, y: Int) -> Point {
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
            _isRandom = false
        }
        _displaySeed = _seed
    }
    
    func generate() {
        initRng()

        _width = Level.getWidthForLevel(_level)
        _height = _width
    
        let numPathPieces = getNumPathPieces()
        _correct = [PointRecord?](repeating: nil, count: numPathPieces + 1)
    
        do {
            _generationStartTime = Date()
            try startWithNumPathPieces(numPathPieces)
            
            if _level > 1 {
                try createDeadEnds()
            }
            
            // Always do this last, because it doesn't add unplanned stops
            if _level > 2 {
                addUselessBlocks(2 * _level)
            }
            
            // There are some possible paths caused by placing a piece that
            // creates a shortcut by connecting unplanned stops using two of
            // the piece's walls. Fixing these would require too much extra
            // time and memory to duplicate the generation state for each iteration.
            if getNumSolutions() != 1 {
                throw LevelError.multipleSolutions
            }
        } catch {
            _seed += 40000
            generate()
        }
    }
    
    func getTrueSeed() -> UInt32 {
        // If every 4 levels have the same width,
        // we need to give them different seeds
        return UInt32(_level % 4) * 10000 + _seed
    }
    
    func initRng() {
        _rng = PseudoRNG(seed: getTrueSeed())
    }
    
    func checkForTimeout() throws {
        if Date().timeIntervalSince(_generationStartTime) > 0.5 {
            throw LevelError.timeout
        }
    }
    
    func getNumPathPieces() -> Int {
        return 1 + (_level - 1) / 3
    }
    
    func startWithNumPathPieces(_ num: Int) throws {
        while true {
            _grid = [PieceType](repeating: .None, count: _width * _height)
            _startX = _rng.next(max: _width)
            _startY = _rng.next(max: _height)
            addStop(x: _startX, y: _startY)
            
            var dirs = PieceType.getNextDirections(.Still)
            if try nextWithNumPathPieces(num, x: _startX, y: _startY, dirs: &dirs, isTruePath: true) {
                break
            }
        }
    }
    
    func nextWithNumPathPieces(_ num: Int, x: Int, y: Int, dirs: inout [Direction], isTruePath: Bool) throws -> Bool {
        try checkForTimeout()
    
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
                let nextPiece = getPieceSafely(point: nextPos)
                if nextPiece.isWallFromDir(dir) {
                    return false
                }
                
                // Make sure a wall can't be placed right in front of this corner
                let lastDir = getPiece(x: x, y: y).getNextDirections(getOppDir(dir))[0]
                let lastPos = getAdjPosFrom(x: x, y: y, dir: lastDir)
                let lastPiece = getPieceSafely(point: lastPos)
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
            let iDir = _rng.next(max: dirs.count)
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
                    let iOffsetIndex = _rng.next(max: offsetIndices.count)
                    let iOffset = offsetIndices[iOffsetIndex]
                    let offset = offsets[iOffset]
            
                    // Add the correct direction to get to each path waypoint
                    if isTruePath {
                        _correct![_correct!.count - num - 1] = PointRecord(x: offset.x, y: offset.y, dir: dir)
                    }
                    
                    // Set path here
                    // We can't use head recursion because the following pieces might
                    // depend on the placement of the current path and piece
                    for i in 0 ..< iOffset {
                        setUsed(point: offsets[i])
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
                        if stopOutsideWallShortcuts(piece: .Target, x: offset.x, y: offset.y, dir: dir) {
                            setPiece(x: offset.x, y: offset.y, type: .Target)
                            return true
                        }
                    } else {
                        let weightedArray = WeightedRandomArray(array: getPiecesFromDir(dir), rng: _rng)
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
                                let nextPiece = getPieceSafely(point: nextPiecePos)
                                if nextPiece == .None {
                                    // The next space is empty. We can place a block there.
                                    addStop(x: offset.x, y: offset.y)
                                    setPiece(x: nextPiecePos.x, y: nextPiecePos.y, type: .Block)
                                    placedNextPiece = true
                                
                                    // Check if this placement created shortcuts connected by new
                                    // unplanned stops
                                    if !stopOutsideWallShortcuts(piece: piece, x: nextPiecePos.x, y: nextPiecePos.y, dir: dir) {
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
                                    let x = _rng.next(max: _width)
                                    let y = _rng.next(max: _height)
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
                                        if allowsTeleporterShortcuts(teleporter: offset, exitX: x, exitY: y, dir: dir) {
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
                                if !stopOutsideWallShortcuts(piece: piece, x: offset.x, y: offset.y, dir: dir) {
                                    continue
                                }
                                
                                // If we're placing a corner, we have nothing else to worry about
                                setPiece(x: offset.x, y: offset.y, type: piece)
                                nextDirs = piece.getNextDirections(dir)
                            }
                            
                            // Move on to the next iteration
                            if !alreadyFailed {
                                if piece.contains(.Teleporter) {
                                    if try nextWithNumPathPieces(num - 1, x: teleporterExit.x, y: teleporterExit.y, dirs: &nextDirs, isTruePath: isTruePath) {
                                    
                                        // Allow dead ends to continue from a Teleporter's dead end
                                        if !isTruePath {
                                            addDirectedStop(x: teleporterExit.x, y: teleporterExit.y, dir: nextDirs[0])
                                        }
                                        
                                        return true
                                    }
                                } else {
                                    if try nextWithNumPathPieces(num - 1, x: offset.x, y: offset.y, dirs: &nextDirs, isTruePath: isTruePath) {
                                        
                                        // Allow dead ends to continue from a Corner's dead end
                                        if !isTruePath && nextDirs.count == 1 {
                                            let nextDir = nextDirs[0]
                                            nextPiecePos = getAdjPosFrom(x: offset.x, y: offset.y, dir: nextDir)
                                            if nextPiecePos.x >= 0 && nextPiecePos.y >= 0 && nextPiecePos.x < _width && nextPiecePos.y < _height {
                                                addDirectedStop(x: nextPiecePos.x, y: nextPiecePos.y, dir: nextDir)
                                            }
                                        }
                                        
                                        return true
                                    }
                                }
                            }
                            
                            // If this iteration had already failed, or the next iteration just failed
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
                    
                    // This offset wasn't valid.
                    // Undo the path and piece placement, and remove the offset index.
                    for i in 0...iOffset {
                        setUnused(point: offsets[i])
                    }
                    offsetIndices.remove(at: iOffsetIndex)
                }
            }
            
            // This direction wasn't valid. Remove it.
            dirs.remove(at: iDir)
        }
    
        // No valid directions. Time to undo?
        return false
    }
    
    func getOffsetsFrom(x: Int, y: Int, dir: Direction) -> [Point] {
        var x = x
        var y = y
        var offsets = [Point]()
        while true {
            switch dir {
                case .Right: x += 1
                case .Up:    y += 1
                case .Left:  x -= 1
                case .Down:  y -= 1
                default: break
            }
            
            // if type is .None, add it to array
            // if type is not .None or .Used, break
            let type = getPieceSafely(point: (x: x, y: y))
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
    
    func getPiecesFromDir(_ dir: Direction) -> [PieceType] {
    
        // Half the time, only allow Blocks
        if _level > 5 && _rng.next(max: 2) == 0 {
            return [PieceType](repeating: .Block, count: 1)
        }
        
        let numOptions = _level <= 2 ? 2 : _level <= 10 ? 3 : 4
        var pieces = [PieceType](repeating: .Block, count: numOptions)
        
        switch dir {
            case .Left:
                pieces[0] = .Corner4
                pieces[1] = .Corner1
            case .Down:
                pieces[0] = .Corner1
                pieces[1] = .Corner2
            case .Right:
                pieces[0] = .Corner2
                pieces[1] = .Corner3
            case .Up:
                pieces[0] = .Corner3
                pieces[1] = .Corner4
            default: break
        }
        if _level > 2 {
            pieces[2] = .Block
        }
        if _level > 10 {
            pieces[3] = .Teleporter
        }
        return pieces
    }
    
    func stopOutsideWallShortcuts(piece: PieceType, x: Int, y: Int, dir: Direction) -> Bool {
        var unplannedStops = [Point]()
        var dirs: [Direction]
        if piece.contains(.Block) || piece.contains(.Target) {
            dirs = [Direction](repeating: .Still, count: 3)
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
            dirs = [Direction](repeating: .Still, count: 2)
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
            if getStopInLineWithPoint(point: point, dir: wallDir, lastPoint: &lastPoint).contains(.Stop) {
                if piece.contains(.Target) || getPieceSafely(point: point).contains(.Teleporter) {
                    return false
                } else {
                    // Now that we would be creating an unplanned stop here,
                    // we must first check if it would create a shortcut
                    let shortcutDirs = PieceType.getNextDirections(wallDir)
                    let additionalUnplannedStops = getUnplannedStopsForPlannedStopAt(x: point.x, y: point.y, dirs: shortcutDirs, visited: Set<PointRecord>())
                    if additionalUnplannedStops == nil {
                        return false
                    }
                    unplannedStops.append(contentsOf: additionalUnplannedStops!)
                    
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
    
    func getStopInLineWithPoint(point: Point, dir: Direction, lastPoint: inout Point?) -> PieceType {
        var point = point
        if lastPoint != nil {
            lastPoint = (x: -1, y: -1)
        }
        
        var usedTeleporters = Set<PointRecord>()
        while true {
            let type = getPieceSafely(point: point)
            
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
    
    func getUnplannedStopsForPlannedStopAt(x: Int, y: Int, dirs: [Direction], visited: Set<PointRecord>) -> [Point]? {
        var visited = visited
    
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
            let extendedSpaceType = getStopInLineWithPoint(point: point, dir: dir, lastPoint: &lastPoint)
            let lastPiece = getPieceSafely(point: lastPoint!)
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
                        coordsForRetroStops.append(contentsOf: additionalCoords!)
                    }
                    coordsForRetroStops.append(lastPoint!)
                }
            }
        }
        
        return coordsForRetroStops
    }

    func isValidTeleporterExitAt(x: Int, y: Int) -> Bool {
        if getPiece(x: x, y: y) != .None {
            return false
        }
        
        var piece = getPieceSafely(point: (x: x - 1, y: y))
        if piece.contains(.Used) || piece == .None {
            return true
        }
        
        piece = getPieceSafely(point: (x: x + 1, y: y))
        if piece.contains(.Used) || piece == .None {
            return true
        }
        
        piece = getPieceSafely(point: (x: x, y: y - 1))
        if piece.contains(.Used) || piece == .None {
            return true
        }
        
        piece = getPieceSafely(point: (x: x, y: y + 1))
        if piece.contains(.Used) || piece == .None {
            return true
        }
        
        return false
    }
    
    func allowsTeleporterShortcuts(teleporter: Point, exitX: Int, exitY: Int, dir: Direction) -> Bool {
        let unplannedStops1 = getTeleporterUnplannedStops(inX: teleporter.x, inY: teleporter.y, outX: exitX, outY: exitY, dir: dir)
        if unplannedStops1 == nil {
            return true
        }

        let unplannedStops2 = getTeleporterUnplannedStops(inX: exitX, inY: exitY, outX: teleporter.x, outY: teleporter.y, dir: getOppDir(dir))
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
        var dirs = [Direction](repeating: .Still, count: 3)
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
            if getStopInLineWithPoint(point: inPos, dir: inDir, lastPoint: &lastPoint).contains(.Stop) {
                let outDir = getOppDir(inDir)
                let outDirs = [Direction](repeating: outDir, count: 1)
                let additionalUnplannedStops = getUnplannedStopsForPlannedStopAt(x: outX, y: outY, dirs: outDirs, visited: Set<PointRecord>())
                if additionalUnplannedStops == nil {
                    return nil
                } else {
                    unplannedStops.append(contentsOf: additionalUnplannedStops!)
                }
            }
        }
        return unplannedStops
    }
    
    func getOppDir(_ dir: Direction) -> Direction {
        switch dir {
        case .Up: return .Down
        case .Down: return .Up
        case .Left: return .Right
        case .Right: return .Left
        default: return .Still
        }
    }
    
// -----------------------------------------------------------------------

    func createDeadEnds() throws {
        var numDeadEnds = 0
        while !_stops.isEmpty {
            let stop = _stops.popLast()!
            
            var dirs: [Direction]!
            if stop.dir == .Still {
                dirs = PieceType.getNextDirections(.Still)
            } else {
                dirs = [Direction](repeating: stop.dir, count: 1)
            }
            for dir in dirs {
                let point = getAdjPosFrom(x: stop.x, y: stop.y, dir: dir)
                if getPieceSafely(point: point) == .None {
                    if try createDeadEnd(point: point, dir: dir) {
                        numDeadEnds += 1
                        break
                    }
                }
            }
        }
    }
    
    func createDeadEnd(point: Point, dir: Direction) throws -> Bool {
        var dirs = [Direction](repeating: dir, count: 1)
        if try nextWithNumPathPieces(1, x: point.x, y: point.y, dirs: &dirs, isTruePath: false) {
            addPiece(x: point.x, y: point.y, type: .Used)
            return true
        }
        return false
    }
    
    func addUselessBlocks(_ num: Int) {
        for x in 0..._width-1 {
            for y in 0..._height-1 {
            
                if getPiece(x: x, y: y) != .None || _rng.next(max: 8) == 0 {
                    continue
                }
                
                var success = true
                let dirs = PieceType.getNextDirections(.Still)
                var lastPoint: Point? = nil
                for dir in dirs {
                    if getStopInLineWithPoint(point: (x: x, y: y), dir: dir, lastPoint: &lastPoint).contains(.Stop) {
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
    
        // Set the difficulty just for the background color
        _level = 45
        _width = 8
        _height = 3
        _grid = [PieceType](repeating: .None, count: _width * _height)
        
        switch (instruction) {
        case 0:
            _startX = 1
            _startY = 1
            setPiece(x: 6, y: 1, type: .Target)
        case 1:
            _startX = 1
            _startY = 1
        case 2:
            _startX = 1
            _startY = 1
        case 3:
            _startX = 4
            _startY = 2
            setPiece(x: 7, y: 2, type: .Block)
            setPiece(x: 6, y: 0, type: .Corner2)
            setPiece(x: 2, y: 0, type: .Corner3)
        case 4:
            _startX = 1
            _startY = 2
            setPiece(x: 5, y: 2, type: .Teleporter)
            _teleporters.append((5,2))
            setPiece(x: 2, y: 1, type: .Teleporter)
            _teleporters.append((2,1))
            break;
        case 5:
            _startX = 1
            _startY = 1
            setPiece(x: 6, y: 1, type: .Target)
        case 6:
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
            
            _correct = [PointRecord(x: 2, y: 1, dir: .Right),
                        PointRecord(x: 2, y: 0, dir: .Down),
                        PointRecord(x: 0, y: 0, dir: .Left),
                        PointRecord(x: 0, y: 2, dir: .Up),
                        PointRecord(x: 3, y: 2, dir: .Right),
                        PointRecord(x: 3, y: 1, dir: .Down),
                        PointRecord(x: 4, y: 1, dir: .Right),
                        PointRecord(x: 4, y: 0, dir: .Down),
                        PointRecord(x: 7, y: 0, dir: .Down)]
        case 7:
            _startX = 1
            _startY = 1
            setPiece(x: 6, y: 1, type: .Target)
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
            setPiece(x: 4, y: 1, type: .Corner3)
            setPiece(x: 4, y: 0, type: .Corner1)
            setPiece(x: 7, y: 0, type: .Target)
        case 10:
            // This is a hack to make the background black
            _level = -50
            _startX = 100
            _startY = 100
        case 11:
            _level = -50
            _startX = 100
            _startY = 100
        default: break
        }
    }
    
// -----------------------------------------------------------------------

    func generateTestLevel() {
        _width = 8
        _height = 8
        _grid = [PieceType](repeating: .None, count: _width * _height)
    
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
