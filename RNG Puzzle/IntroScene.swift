//
//  IntroScene.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 9/24/15.
//  Copyright © 2015 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit

class IntroScene: SKScene, GKGameCenterControllerDelegate, Refreshable {

    var _titleLabel: SKLabelNode! = nil
    var _portalSprite: SKSpriteNode! = nil
    var _playLabel: SKLabelNode! = nil
    var _myLevelsIcon: SKSpriteNode! = nil
    var _myLevelsLabel: SKLabelNode! = nil
    var _itemsIcon: SKSpriteNode! = nil
    var _itemsLabel: SKLabelNode! = nil
    var _instructionsIcon: SKSpriteNode! = nil
    var _instructionsLabel: SKLabelNode! = nil
    var _leaderboardIcon: SKSpriteNode! = nil
    var _leaderboardLabel: SKLabelNode! = nil
    var _muteShareDisplay: MuteShareDisplay! = nil
    var _starEmitter: SKEmitterNode! = nil
    
    var _foregroundNotification: NSObjectProtocol! = nil
    
    let _cycleTime = 60.0
    var _startTime: CFTimeInterval? = nil
    var _maxLevel = 1
    
    deinit {
        NotificationCenter.default.removeObserver(_foregroundNotification)
    }

    override func didMove(to view: SKView) {
        removeAllChildren()
        backgroundColor = SKColor.black
        
        // Title
        _titleLabel = addLabel("Astro Maze", color: Constants.TITLE_COLOR)
        
        // Play
        _portalSprite = SKSpriteNode(texture: PieceSprites().target())
        _portalSprite.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 0.5)))
        _portalSprite.zPosition = -1
        addChild(_portalSprite)
        _playLabel = addLabel("Play", color: SKColor.white)
        
        // My Puzzles
        _myLevelsIcon = SKSpriteNode(imageNamed: "icon_my_puzzles")
        addChild(_myLevelsIcon)
        _myLevelsLabel = addLabel("Create", color: SKColor.white)
        
        // Items
        _itemsIcon = SKSpriteNode(imageNamed: "icon_items")
        addChild(_itemsIcon)
        _itemsLabel = addLabel("Items", color: SKColor.white)
        
        // Help
        _instructionsIcon = SKSpriteNode(imageNamed: "icon_help")
        addChild(_instructionsIcon)
        _instructionsLabel = addLabel("Help", color: SKColor.white)
        
        // Scores
        _leaderboardIcon = SKSpriteNode(imageNamed: "icon_scores")
        addChild(_leaderboardIcon)
        _leaderboardLabel = addLabel("Scores", color: SKColor.white)

        // Social
        _muteShareDisplay = MuteShareDisplay(shareType: .App)
        addChild(_muteShareDisplay)
        
        createStars()

        refreshLayout()

//        authenticateLocalPlayer()
    }
    
//    func authenticateLocalPlayer() {
//        let localPlayer = GKLocalPlayer.localPlayer()
//        
//        localPlayer.authenticateHandler = {(viewController, error) -> Void in
//            if error != nil {
//                NSLog(error!.localizedDescription)
//            } else if viewController != nil {
//                AlertManager.defaultManager().getTopViewController().presentViewController(viewController!, animated: true, completion: nil)
//            } else if (localPlayer.authenticated) {
//                NSLog("player authenticated")
//            } else {
//                NSLog("player could not be authenticated")
//            }
//        }
//    }
    
    func createStars() {
        let path = Bundle.main.path(forResource: "StarBackground", ofType: "sks")
        _starEmitter = NSKeyedUnarchiver.unarchiveObject(withFile: path!) as! SKEmitterNode
        _starEmitter.targetNode = self
        _starEmitter.zPosition = -10
        
        refreshStars()
        self.addChild(_starEmitter)
        
        _foregroundNotification = NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground, object: nil, queue: nil, using: { Void in self._starEmitter.resetSimulation() })
    }
    
    func refreshStars() {
        if _starEmitter != nil {
            let w = size.width
            let h = size.height
            
            _starEmitter.position = CGPoint(x: w / 2, y: h / 2)
            _starEmitter.particlePositionRange = CGVector(dx: frame.width, dy: frame.height)
            _starEmitter.particleBirthRate = CGFloat(Storage.loadMaxLevel() - 1) * 0.2
        }
    }
    
    func refresh() {
        refreshStars()
    }
    
    func addLabel(_ text: String, color: SKColor) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: Constants.FONT)
        label.text = text
        label.fontColor = color
        self.addChild(label)
        return label
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let p = touch.location(in: self)
        
        let distToPlay = pow(p.x - _portalSprite.position.x, 2) + pow(p.y - _portalSprite.position.y, 2)
        
        if distToPlay < pow(_portalSprite.size.width / 2, 2) {
            AppDelegate.pushViewController(SKViewController(scene: LevelSelectScene()), animated: true, offset: 0)
        } else if isPointInBounds(p, node: _itemsIcon) {
            ///////////////////////
            // TODO: Item Shop //
            ///////////////////////
        } else if isPointInBounds(p, node: _leaderboardIcon) {
            displayLeaderboard()
        } else if isPointInBounds(p, node: _instructionsIcon) {
            AppDelegate.pushViewController(SKViewController(scene: InstructionsScene()), animated: true, offset: 0)
        } else if isPointInBounds(p, node: _myLevelsIcon) {
            AppDelegate.pushViewController(MyPuzzlesController(), animated: true, offset: 0)
        } else {
            // We don't have to transform the point because the display is at the origin
            _muteShareDisplay.tap(p)
        }
    }
    
    func isPointInBounds(_ p: CGPoint, node: SKNode) -> Bool {
        let w = size.width
        let h = size.height
        let s = min(w, h)
        let margin = s * 0.05
        
        let x1 = node.frame.minX - margin
        let x2 = node.frame.maxX + margin
        let y1 = node.frame.minY - margin
        let y2 = node.frame.maxY + margin
        if p.x > x1 && p.x < x2 && p.y > y1 && p.y < y2 {
            return true
        }
        return false
    }
    
    func displayLeaderboard() {
//        let gcViewController = GKGameCenterViewController()
//        gcViewController.gameCenterDelegate = self
//        gcViewController.viewState = .Achievements
//        AlertManager.defaultManager().getTopViewController().presentViewController(gcViewController, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    func refreshLayout() {
        if _titleLabel == nil {
            return
        }
    
        let w = size.width
        let h = size.height
        let s = min(w, h)
        
        _titleLabel.fontSize = s * 0.16
        _titleLabel.position = CGPoint(x: w * 0.5, y: h * 0.85)
        
        
        let playY = h * 0.57
        let playSize = s * 0.12
        
        _portalSprite.size = CGSize(width: s * 0.5, height: s * 0.5)
        _portalSprite.position = CGPoint(x: w * 0.5, y: playY + playSize * 0.4)
        _playLabel.fontSize = playSize
        _playLabel.position = CGPoint(x: w * 0.5, y: playY)


        let iconY = h * 0.33
        let iconSize = s * 0.1
        let labelSize = s * Constants.TEXT_SCALE * 0.5
        let labelY = iconY - s * 0.11
        
        _itemsIcon.size = CGSize(width: iconSize, height: iconSize)
        _itemsIcon.position = CGPoint(x: w * 0.17, y: iconY)
        _itemsLabel.fontSize = labelSize
        _itemsLabel.position = CGPoint(x: w * 0.17, y: labelY)
        
        _leaderboardIcon.size = CGSize(width: iconSize, height: iconSize)
        _leaderboardIcon.position = CGPoint(x: w * 0.39, y: iconY)
        _leaderboardLabel.fontSize = labelSize
        _leaderboardLabel.position = CGPoint(x: w * 0.39, y: labelY)
        
        _instructionsIcon.size = CGSize(width: iconSize, height: iconSize)
        _instructionsIcon.position = CGPoint(x: w * 0.61, y: iconY)
        _instructionsLabel.fontSize = labelSize
        _instructionsLabel.position = CGPoint(x: w * 0.61, y: labelY)
        
        _myLevelsIcon.size = CGSize(width: iconSize, height: iconSize)
        _myLevelsIcon.position = CGPoint(x: w * 0.83, y: iconY)
        _myLevelsLabel.fontSize = labelSize
        _myLevelsLabel.position = CGPoint(x: w * 0.83, y: labelY)

        _muteShareDisplay.position = CGPoint.zero
        _muteShareDisplay.refreshLayout(size: size)
        
        refreshStars()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        refreshLayout()
    }
}
