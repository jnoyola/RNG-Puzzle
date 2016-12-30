//
//  CreatedLevel.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 3/27/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import Foundation

class CustomLevel: NSObject, LevelProtocol {

    typealias Point = (x: Int, y: Int)

    var _level = 2
    var _seed = ""
    
    var _width = 2
    var _height = 2
    var _startX = -1
    var _startY = -1
    var _targetX = -1
    var _targetY = -1
    var _grid: [[PieceType]]! = nil
    var _teleporters: [Point?]! = nil
    
    var _correct: [PointRecord]? = nil
    
    
    @inline(__always) func getCode() -> String {
        return "\(_level).\(_seed)"
    }
    
    @inline(__always) func getSeedString() -> String {
        let prefix = (_seed as NSString).substring(to: 4)
        return "\(prefix)..."
    }
    
    @inline(__always) func getPiece(x: Int, y: Int) -> PieceType {
        return _grid[y][x]
    }
    
    @inline(__always) func setPiece(x: Int, y: Int, type: PieceType) {
        _grid[y][x] = type
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
            if p0 == nil {
                break
            }
            if x == p0!.x && y == p0!.y {
                if (i % 2) == 0 {
                    if _teleporters.count == i + 1 {
                        // Maybe passing through teleporter in Creation
                        // whose pair has not yet been placed.
                        return (-1, -1)
                    }
                    return _teleporters[i + 1]!
                } else {
                    return _teleporters[i - 1]!
                }
            }
        }
        NSLog("ERROR  (\(_level).\(_seed)): teleporter match for (\(x),\(y)) not found")
        return (-1, -1)
    }
    
// -----------------------------------------------------------------------

    init?(level: Int, seed: String?) {
        super.init()
    
        _level = level
        if seed == nil {
            createNew()
        } else if !loadFromSeed(seed!) {
            return nil
        }
    }
    
    func generate(debug: Bool) -> Bool {
        return true
    }
    
    func createNew() {
        _width = CustomLevel.getWidthForLevel(_level)
        _height = _width
        _grid = [[PieceType]!](repeating: nil, count: _height)
        for j in 0...(_height - 1) {
            _grid[j] = [PieceType](repeating: .None, count: _width)
        }
        _teleporters = []
    }
    
    func loadFromSeed(_ seed: String) -> Bool {
        _seed = seed
        if let data = NSData(base64Encoded: seed, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) {
            var bytes = [UInt8](repeating: 0, count: data.length)
            data.getBytes(&bytes, length: bytes.count)
            
            if bytes.count < 6 {
                return false
            }
        
            _width   = Int(bytes[0])
            _height  = Int(bytes[1])
            _startX  = Int(bytes[2])
            _startY  = Int(bytes[3])
            _targetX = Int(bytes[4])
            _targetY = Int(bytes[5])
            let wRange = CustomLevel.getLevelRangeForWidth(_width)
            let hRange = CustomLevel.getLevelRangeForWidth(_height)
            let minLevel = (wRange.min + hRange.min) / 2
            let maxLevel = (wRange.max + hRange.max) / 2
            if _width < 1 ||
               _height < 1 ||
               _startX < 0 ||
               _startY < 0 ||
               _targetX < 0 ||
               _targetY < 0 ||
               _startX >= _width ||
               _startY >= _height ||
               _targetX >= _width ||
               _targetY >= _height ||
               _level < minLevel ||
               _level > maxLevel {
                return false
            }
            
            _grid = [[PieceType]!](repeating: nil, count: _height)
            for j in 0...(_height - 1) {
                _grid[j] = [PieceType](repeating: .None, count: _width)
            }
            _teleporters = [Point?](repeating: nil, count: 64)
            
            /* We are descending down this tree, where 0s go left, 1s go right,
             * and each branch has a state label. The state following a 
             * .Teleporter reads its 5 bit ID
             *
             *        (0)
             *      0/   \1
             *  .None    (1)
             *         0/   \1
             *        (2)   (3)
             *      0/ |1   0| \1
             * .Block .Tele  |  \
             *         |    (4) (5)
             *        (6)  0/ |1 0| \1
             *          .C1 .C2 .C3 .C4
             *
             */
            
            var iByte = 6 // Following the 6 meta bytes above
            var iBit = 8
            var state = 0
            var teleporterID = 0
            var numTeleporterIDBits = 0
            var i = 0
            var j = 0
            while iByte < bytes.count {
                iBit -= 1
                let bit = bytes[iByte] & UInt8(1 << iBit)
                if iBit == 0 {
                    iBit = 8
                    iByte += 1
                }
                
                var type: PieceType? = nil
                switch state {
                case 0:
                    if bit != 0 { state = 1 }
                    else        { type = PieceType.None }
                case 1:
                    if bit != 0 { state = 3 }
                    else        { state = 2 }
                case 2:
                    if bit != 0 { state = 6 }
                    else        { type = PieceType.Block }
                case 3:
                    if bit != 0 { state = 5 }
                    else        { state = 4 }
                case 4:
                    if bit != 0 { type = PieceType.Corner2 }
                    else        { type = PieceType.Corner1 }
                case 5:
                    if bit != 0 { type = PieceType.Corner4 }
                    else        { type = PieceType.Corner3 }
                case 6:
                    teleporterID <<= 1
                    if bit != 0 {
                        teleporterID |= 1
                    }
                    numTeleporterIDBits += 1
                    if numTeleporterIDBits == 5 {
                        type = PieceType.Teleporter
                    }
                default: return false
                }
                
                if type != nil {
                    if type != .none {
                        setPiece(x: i, y: j, type: type!)
                        if type == .Teleporter {
                            setTeleporterForID(x: i, y: j, id: teleporterID)
                            teleporterID = 0
                            numTeleporterIDBits = 0
                        }
                    }
                    state = 0
                    i += 1
                    if i == _width {
                        j += 1
                        if j == _height {
                            break
                        }
                        i = 0
                    }
                }
            }
            
            var numTeleporters = -1
            while numTeleporters < _teleporters.count - 1 {
                numTeleporters += 1
                if _teleporters[numTeleporters] == nil {
                    _teleporters.removeLast(_teleporters.count - numTeleporters)
                    break
                }
            }
            if _teleporters.count % 2 == 1 {
                return false
            }
        } else {
            return false
        }
        
        setPiece(x: _targetX, y: _targetY, type: .Target)
        
        if getPiece(x: _startX, y: _startY) != .None {
            return false
        }
        
        return true
    }
    
    func setTeleporterForID(x: Int, y: Int, id: Int) {
        if _teleporters[2 * id] == nil {
            _teleporters[2 * id] = (x: x, y: y)
        } else {
            _teleporters[2 * id + 1] = (x: x, y: y)
        }
    }
    
    func getTeleporterID(x: Int, y: Int) -> Int {
        for i in 0...(_teleporters.count - 1) {
            let teleporter = _teleporters[i]
            if teleporter == nil {
                break
            }
            if teleporter!.x == x && teleporter!.y == y {
                return Int(i / 2)
            }
        }
        return -1
    }
    
    func computeSeed() {
        updateLevel()
    
        var bytes = [
            UInt8(_width),
            UInt8(_height),
            UInt8(_startX),
            UInt8(_startY),
            UInt8(_targetX),
            UInt8(_targetY),
        ]
        
        var byte: UInt8 = 0
        var iBit: UInt8 = 8
        var iPieceBit = 0
        var pieceDone = false
        var teleporterID: UInt8 = 0
        var numTeleporterIDBits: UInt8 = 5
        for j in 0...(_height - 1) {
            for i in 0...(_width - 1) {
                let type = getPiece(x: i, y: j)
                iPieceBit = 0
                pieceDone = false
                if type == .Teleporter {
                    teleporterID = UInt8(getTeleporterID(x: i, y: j))
                    numTeleporterIDBits = 5
                }
                while true {
                    iBit -= 1
                    
                    if type == .Block {
                        // 1 0 0
                        switch iPieceBit {
                        case 0: byte |= (1 << iBit)
                        case 1: break
                        case 2: fallthrough
                        default: pieceDone = true
                        }
                    } else if type == .Teleporter {
                        // 1 0 1 _ _ _ _ _ (ID)
                        switch iPieceBit {
                        case 0: byte |= (1 << iBit)
                        case 1: break
                        case 2: byte |= (1 << iBit)
                        default:
                            numTeleporterIDBits -= 1
                            byte |= (((teleporterID >> numTeleporterIDBits) & 1) << iBit)
                            if numTeleporterIDBits == 0 {
                                pieceDone = true
                            }
                        }
                    } else if type == .Corner1 {
                        // 1 1 0 0
                        switch iPieceBit {
                        case 0: byte |= (1 << iBit)
                        case 1: byte |= (1 << iBit)
                        case 2: break
                        case 3: fallthrough
                        default: pieceDone = true
                        }
                    } else if type == .Corner2 {
                        // 1 1 0 1
                        switch iPieceBit {
                        case 0: byte |= (1 << iBit)
                        case 1: byte |= (1 << iBit)
                        case 2: break
                        case 3: byte |= (1 << iBit)
                            pieceDone = true
                        default: pieceDone = true
                        }
                    } else if type == .Corner3 {
                        // 1 1 1 0
                        switch iPieceBit {
                        case 0: byte |= (1 << iBit)
                        case 1: byte |= (1 << iBit)
                        case 2: byte |= (1 << iBit)
                        case 3: fallthrough
                        default: pieceDone = true
                        }
                    } else if type == .Corner4 {
                        // 1 1 1 1
                        switch iPieceBit {
                        case 0: byte |= (1 << iBit)
                        case 1: byte |= (1 << iBit)
                        case 2: byte |= (1 << iBit)
                        case 3: byte |= (1 << iBit)
                            pieceDone = true
                        default: pieceDone = true
                        }
                    } else { // .None
                        // 0
                        pieceDone = true
                    }
                    
                    if iBit == 0 {
                        bytes.append(byte)
                        iBit = 8
                        byte = 0
                    }
                    
                    if pieceDone {
                        break
                    }
                    iPieceBit += 1
                }
            }
        }
        
        // Add final byte if incomplete
        if iBit < 8 {
            bytes.append(byte)
        }
        
        let data = NSData(bytes: &bytes, length: bytes.count)
        _seed = data.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
    }
    
    func canDecWidth() -> Bool {
        return _width > 4
    }
    
    func canDecHeight() -> Bool {
        return _height > 4
    }
    
    func canIncWidth() -> Bool {
        return _width < CustomLevel.getWidthForLevel(Storage.loadMaxLevel()) && _width < 750
    }
    
    func canIncHeight() -> Bool {
        return _height < CustomLevel.getWidthForLevel(Storage.loadMaxLevel()) && _height < 750
    }
    
    func incLeft() {
        for j in 0...(_height - 1) {
            _grid[j].insert(.None, at: 0)
        }
        changeOrigin(dx: 1)
        _width += 1
        updateLevel()
    }
    
    func decLeft() {
        // Need 2 separate loops so that origin is stable
        // in case we're removing teleporter pairs
        for j in 0...(_height - 1) {
            checkRemovedPiece(x: 0, y: j)
        }
        for j in 0...(_height - 1) {
            _grid[j].removeFirst()
        }
        changeOrigin(dx: -1)
        _width -= 1
        updateLevel()
    }
    
    func incRight() {
        for j in 0...(_height - 1) {
            _grid[j].append(.None)
        }
        _width += 1
        updateLevel()
    }
    
    func decRight() {
        // See comment for decLeft()
        for j in 0...(_height - 1) {
            checkRemovedPiece(x: _width - 1, y: j)
        }
        for j in 0...(_height - 1) {
            _grid[j].removeLast()
        }
        _width -= 1
        updateLevel()
    }
    
    func incBottom() {
        let row = [PieceType](repeating: .None, count: _width)
        _grid.insert(row, at: 0)
        changeOrigin(dy: 1)
        _height += 1
        updateLevel()
    }
    
    func decBottom() {
        for i in 0...(_width - 1) {
            checkRemovedPiece(x: i, y: 0)
        }
        _grid.removeFirst()
        changeOrigin(dy: -1)
        _height -= 1
        updateLevel()
    }
    
    func incTop() {
        let row = [PieceType](repeating: .None, count: _width)
        _grid.append(row)
        _height += 1
        updateLevel()
    }
    
    func decTop() {
        for i in 0...(_width - 1) {
            checkRemovedPiece(x: i, y: _height - 1)
        }
        _grid.removeLast()
        _height -= 1
        updateLevel()
    }
    
    func updateLevel() {
        let wRange = CustomLevel.getLevelRangeForWidth(_width)
        let hRange = CustomLevel.getLevelRangeForWidth(_height)
        let minLevel = (wRange.min + hRange.min) / 2
        let maxLevel = (wRange.max + hRange.max) / 2
        if _level < minLevel || _level > maxLevel {
            _level = (minLevel + maxLevel) / 2
        }
    }
    
    func checkRemovedPiece(x: Int, y: Int) {
        let piece = getPiece(x: x, y: y)
    
        if piece == .Teleporter {
            removeTeleporter(point: (x: x, y: y))
        } else if x == _startX && y == _startY {
            _startX = -1
            _startY = -1
        } else if x == _targetX && y == _targetY {
            _targetX = -1
            _targetY = -1
        }
    }
    
    func changeOrigin(dx: Int = 0, dy: Int = 0) {
        for i in 0 ..< _teleporters.count {
            let p = _teleporters[i]
            if p == nil {
                break
            }
            _teleporters[i] = (x: p!.x + dx, y: p!.y + dy)
        }
        
        if _startX >= 0 {
            _startX += dx
            _startY += dy
        }
        
        if _targetX >= 0 {
            _targetX += dx
            _targetY += dy
        }
    }
    
// -----------------------------------------------------------------------

    func removeTeleporter(point: Point) {
        let id = getTeleporterID(x: point.x, y: point.y)
        if id < 0 {
            return
        }
        
        let t1 = _teleporters.remove(at: id * 2)
        
        // Make sure there's another teleporter to remove
        if id * 2 >= _teleporters.count {
            return
        }
        
        let t2 = _teleporters.remove(at: id * 2)
        
        if t1!.x != point.x || t1!.y != point.y {
            setPiece(x: t1!.x, y: t1!.y, type: .None)
        } else {
            setPiece(x: t2!.x, y: t2!.y, type: .None)
        }
    }
}
