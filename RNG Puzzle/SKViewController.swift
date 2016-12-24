//
//  SKViewController.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 4/9/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import AVKit
import AVFoundation
import GoogleMobileAds
import SpriteKit
import UIKit

class SKViewController: UIViewController, ALAdDisplayDelegate, Refreshable {

    var _scene: SKScene! = nil
    var _presentingAd = false

    init(scene: SKScene) {
        super.init(nibName: nil, bundle: nil)
        _scene = scene
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func refresh() {
        (_scene as? Refreshable)?.refresh()
    }

    override func loadView() {
        view = SKView(frame: UIScreen.mainScreen().bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        _scene.scaleMode = .ResizeFill
        skView.presentScene(_scene)
        
        
        
        if _scene is CreationScene && false {
            if GADRewardBasedVideoAd.sharedInstance().ready {
                _presentingAd = true
                GADRewardBasedVideoAd.sharedInstance().presentFromRootViewController(self)
                GADRewardBasedVideoAd.sharedInstance().loadRequest(GADRequest(), withAdUnitID: "ca-app-pub-7708975293508353/5034943423")
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    self._presentingAd = false
                }
            } else if ALIncentivizedInterstitialAd.isReadyForDisplay() {
                _presentingAd = true
                ALIncentivizedInterstitialAd.shared().adDisplayDelegate = self
                ALIncentivizedInterstitialAd.showAndNotify(nil)
            }
        }
    }
    
    func ad(ad: ALAd, wasDisplayedIn view: UIView) {}
    func ad(ad: ALAd, wasClickedIn view: UIView) {}
    func ad(ad: ALAd, wasHiddenIn view: UIView) {
        _presentingAd = false
        ALIncentivizedInterstitialAd.preloadAndNotify(nil)
    }
    
    override func viewWillAppear(animated: Bool) {
//        navigationController!.setToolbarHidden(true, animated: true)
        navigationController!.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        /*if !_presentingAd {
            _scene.willMoveFromView(view as! SKView)
        }*/
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
