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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Storage.registerDefaults()
        ProductManager.defaultManager().requestProductInfo()
        prepareAdNetworks()
        
        navigationController = UINavigationController.init(navigationBarClass: NavigationBar.self, toolbarClass: nil)
        navigationController.setViewControllers([MainViewController()], animated: false)
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        return true
    }
    
    func prepareAdNetworks() {
        let request = GADRequest()
        
        // AppLovin
        ALSdk.initializeSdk()
        ALIncentivizedInterstitialAd.preloadAndNotify(nil)
        
        // Chartboost
        Chartboost.startWithAppId("570e0b5904b01631082c6632", appSignature: "820bc446b84f166002daab63ceb3ad18ef5ca1df", delegate: self)
        request.registerAdNetworkExtras(GADMChartboostExtras())
        
        // Unity Ads
        UnityAds.sharedInstance().startWithGameId("1058583")
        UnityAds.sharedInstance().setZone("rewardedVideo")
        
        // Vungle
        VungleSDK.sharedSDK().startWithAppId("570e047bb5378a7608000049")
        
        //GADRewardBasedVideoAd.sharedInstance().delegate = self
        GADRewardBasedVideoAd.sharedInstance().loadRequest(request, withAdUnitID: "ca-app-pub-7708975293508353/5034943423")
        NSLog("AdID: \(ASIdentifierManager.sharedManager().advertisingIdentifier)")
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
    
    static func pushViewController(viewController: UIViewController, animated: Bool, offset: Int) {
        let nav = (UIApplication.sharedApplication().delegate! as! AppDelegate).navigationController
        var controllers = [UIViewController]()
        for i in 0 ..< (nav.viewControllers.count - 1 + offset) {
            if i < nav.viewControllers.count {
                controllers.append(nav.viewControllers[i])
            }
        }
        controllers.append(viewController)
        
        nav.setViewControllers(controllers, animated: animated)
    }
    
    static func popViewController(animated animated: Bool) {
        let nav = (UIApplication.sharedApplication().delegate! as! AppDelegate).navigationController
        if nav.viewControllers.count == 1 {
            let controllers = [MainViewController(), nav.viewControllers[0]]
            nav.setViewControllers(controllers, animated: false)
        }
        nav.popViewControllerAnimated(animated)
        (nav.viewControllers.last as? Refreshable)?.refresh()
    }
    
//    func pushViewController(viewController: UIViewController, animated: Bool) {
//        navigationController.setViewControllers([navigationController.viewControllers[0], viewController], animated: animated)
//    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

