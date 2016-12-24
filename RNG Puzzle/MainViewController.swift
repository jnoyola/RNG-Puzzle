//
//  MainViewController.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 9/24/15.
//  Copyright (c) 2015 iNoyola. All rights reserved.
//

import MessageUI
import Social
import SpriteKit
import UIKit

class MainViewController: UIViewController, Refreshable {

    var _scene: SKScene! = nil

    override func loadView() {
        view = SKView(frame: UIScreen.mainScreen().bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let skView = view as! SKView
        _scene = IntroScene(size: view.bounds.size)
        skView.ignoresSiblingOrder = true
        _scene.scaleMode = .ResizeFill
        skView.presentScene(_scene)
    }
    
    func refresh() {
        (_scene as? Refreshable)?.refresh()
    }
    
    override func viewWillAppear(animated: Bool) {
//        navigationController!.setToolbarHidden(true, animated: true)
        navigationController!.setNavigationBarHidden(true, animated: true)
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .AllButUpsideDown
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
