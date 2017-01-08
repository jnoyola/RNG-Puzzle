//
//  AppDelegate.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 9/24/15.
//  Copyright © 2015 iNoyola. All rights reserved.
//

import UIKit
import GoogleMobileAds
import AdSupport

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, /*GADRewardBasedVideoAdDelegate,*/ ChartboostDelegate {

    var navigationController: UINavigationController!
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Storage.registerDefaults()
        ProductManager.defaultManager().requestProductInfo()
        prepareAdNetworks()
        
        navigationController = UINavigationController.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)
        navigationController.setViewControllers([MainViewController()], animated: false)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
    
    func prepareAdNetworks() {
        let request = GADRequest()
        
        // AppLovin
        ALSdk.initializeSdk()
        ALIncentivizedInterstitialAd.preloadAndNotify(nil)
        request.register(GADMExtrasAppLovin())
        
        // Chartboost
        Chartboost.start(withAppId: "570e0b5904b01631082c6632", appSignature: "820bc446b84f166002daab63ceb3ad18ef5ca1df", delegate: self)
        request.register(GADMChartboostExtras())
        
        // Vungle
        VungleSDK.shared().start(withAppId: "570e047bb5378a7608000049")
        request.register(VungleAdNetworkExtras())
        
        //GADRewardBasedVideoAd.sharedInstance().delegate = self
        GADRewardBasedVideoAd.sharedInstance().load(request, withAdUnitID: "ca-app-pub-7708975293508353/5034943423")
        NSLog("AdID: \(ASIdentifierManager.shared().advertisingIdentifier)")
    }
    
    /*
    // AdMob
    func rewardBasedVideoAdDidReceiveAd(rewardBasedVideoAd: GADRewardBasedVideoAd!) {
        NSLog("============== received")
    }
    func rewardBasedVideoAdDidOpen(rewardBasedVideoAd: GADRewardBasedVideoAd!) {
        NSLog("============== opened")
    }
    func rewardBasedVideoAdDidStartPlaying(rewardBasedVideoAd: GADRewardBasedVideoAd!) {
        NSLog("============== started playing")
    }
    func rewardBasedVideoAdDidClose(rewardBasedVideoAd: GADRewardBasedVideoAd!) {
        NSLog("============== did close")
    }
    func rewardBasedVideoAdWillLeaveApplication(rewardBasedVideoAd: GADRewardBasedVideoAd!) {
        NSLog("============== will leave app")
    }
    func rewardBasedVideoAd(rewardBasedVideoAd: GADRewardBasedVideoAd!, didRewardUserWithReward reward: GADAdReward!) {
        NSLog("============== did reward with \(reward.amount) of \(reward.type)")
    }
    func rewardBasedVideoAd(rewardBasedVideoAd: GADRewardBasedVideoAd!, didFailToLoadWithError error: NSError!) {
        NSLog("============== did fail to load with error: \(error)")
    }
    */
    
    static func pushViewController(_ viewController: UIViewController, animated: Bool, offset: Int) {
        let nav = (UIApplication.shared.delegate! as! AppDelegate).navigationController
        var controllers = [UIViewController]()
        for i in 0 ..< ((nav?.viewControllers.count)! - 1 + offset) {
            if i < (nav?.viewControllers.count)! {
                controllers.append((nav?.viewControllers[i])!)
            }
        }
        controllers.append(viewController)
        
//        let transition = CATransition()
//        transition.type = kCATransitionFade
//        nav?.view.layer.add(transition, forKey: kCATransition)
        
        nav?.setViewControllers(controllers, animated: animated)
    }
    
    static func popViewController(animated: Bool) {
        if let nav = (UIApplication.shared.delegate! as! AppDelegate).navigationController {
            if nav.viewControllers.count == 1 {
                let controllers: [UIViewController] = [MainViewController(), nav.viewControllers[0]]
                nav.setViewControllers(controllers, animated: false)
            }
            nav.popViewController(animated: animated)
            (nav.viewControllers.last as? Refreshable)?.refresh()
        }
    }
    
//    func pushViewController(viewController: UIViewController, animated: Bool) {
//        navigationController.setViewControllers([navigationController.viewControllers[0], viewController], animated: animated)
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        let nav = (UIApplication.shared.delegate! as! AppDelegate).navigationController
        if let skvc = nav?.viewControllers.last as? SKViewController {
            if let playScene = skvc._scene as? PlayScene {
                playScene.doPause()
            }
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

