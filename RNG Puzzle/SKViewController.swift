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
        view = SKView(frame: UIScreen.main.bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        _scene.scaleMode = .resizeFill
        skView.presentScene(_scene)
        
        
        
        if _scene is CreationScene && false {
            if GADRewardBasedVideoAd.sharedInstance().isReady {
                _presentingAd = true
                GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
                GADRewardBasedVideoAd.sharedInstance().load(GADRequest(), withAdUnitID: "ca-app-pub-7708975293508353/5034943423")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self._presentingAd = false
                }
            } /*else if ALIncentivizedInterstitialAd.isReadyForDisplay() {
                _presentingAd = true
                ALIncentivizedInterstitialAd.shared().adDisplayDelegate = self
                ALIncentivizedInterstitialAd.showAndNotify(nil)
            }*/
        }
    }
    
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView) {}
    func ad(_ ad: ALAd, wasClickedIn view: UIView) {}
    func ad(_ ad: ALAd, wasHiddenIn view: UIView) {
        _presentingAd = false
        ALIncentivizedInterstitialAd.preloadAndNotify(nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        navigationController!.setToolbarHidden(true, animated: true)
        navigationController!.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        /*if !_presentingAd {
            _scene.willMoveFromView(view as! SKView)
        }*/
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
}
