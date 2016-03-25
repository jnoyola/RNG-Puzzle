//
//  MainViewController.swift
//  RNG Puzzle
//
//  Created by Jonathan Noyola on 9/24/15.
//  Copyright (c) 2015 iNoyola. All rights reserved.
//

import UIKit
import SpriteKit
import Social
import MessageUI

class MainViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    override func loadView() {
        view = SKView(frame: UIScreen.mainScreen().bounds)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        let scene = IntroScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .ResizeFill
        skView.presentScene(scene)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "shareMessages:", name: "shareMessages", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "shareFacebook:", name: "shareFacebook", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "shareTwitter:", name: "shareTwitter", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "alert:", name: "alert", object: nil)
    }
    
    func shareMessages(notification: NSNotification) {
        if MFMessageComposeViewController.canSendText()
        {
            let vcMessages = MFMessageComposeViewController()
            vcMessages.body="Check out AI Puzzle in the App Store!\nhttps://itunes.apple.com/us/app/id1096009046"
            
//            controller.addAttachmentData(UIImageJPEGRepresentation(UIImage(named: "images.jpg")!, 1)!, typeIdentifier: "image/jpg", filename: "images.jpg")

            vcMessages.messageComposeDelegate = self

            self.presentViewController(vcMessages, animated: true, completion: nil)
        }
        else
        {
            self.showAlertMessage("Messaging is unavailable.")
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func shareFacebook(notification: NSNotification) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let vcFacebook = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
     
            vcFacebook.addURL(NSURL(string: "https://itunes.apple.com/us/app/id1096009046"))
     
            self.presentViewController(vcFacebook, animated: true, completion: nil)
        } else {
            self.showAlertMessage("You are not logged in to Facebook.")
        }
    }
    
    func shareTwitter(notification: NSNotification) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            // Initialize the default view controller for sharing the post.
            let vcTwitter = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
     
            let text = "Check out AI Puzzle in the App Store!\nhttps://itunes.apple.com/us/app/id1096009046 #AIPuzzle"
            vcTwitter.setInitialText(text)
     
//            // Set the note text as the default post message.
//            if count(self.noteTextview.text) <= 140 {
//                twitterComposeVC.setInitialText("\(self.noteTextview.text)")
//            }
//            else {
//                let index = advance(self.noteTextview.text.startIndex, 140)
//                let subText = self.noteTextview.text.substringToIndex(index)
//                twitterComposeVC.setInitialText("\(subText)")
//            }
     
            self.presentViewController(vcTwitter, animated: true, completion: nil)
        }
        else {
            self.showAlertMessage("You are not logged in to Twitter.")
        }
    }
    
    func showAlertMessage(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func alert(notification: NSNotification) {
        let userInfo:Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        showAlertMessage(userInfo["message"]!)
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
