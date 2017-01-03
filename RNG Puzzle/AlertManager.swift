//
//  AlertManager.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 4/22/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import MessageUI
import Social
import UIKit

class AlertManager: NSObject, MFMessageComposeViewControllerDelegate {

    static var _default: AlertManager? = nil
    static func defaultManager() -> AlertManager {
        if _default == nil {
            _default = AlertManager()
        }
        return _default!
    }

    func getTopViewController() -> UIViewController {
        return (UIApplication.shared.delegate!.window!!.rootViewController! as! UINavigationController).visibleViewController!
    }
    
    func shareMessages(type: MuteShareDisplay.ShareType, level: LevelProtocol?, duration: Int) {
        if MFMessageComposeViewController.canSendText()
        {
            let vcMessages = MFMessageComposeViewController()
            vcMessages.body="Check out Astro Maze in the App Store!\nhttps://itunes.apple.com/us/app/id1134843213"
            
//            controller.addAttachmentData(UIImageJPEGRepresentation(UIImage(named: "images.jpg")!, 1)!, typeIdentifier: "image/jpg", filename: "images.jpg")

            vcMessages.messageComposeDelegate = self

            getTopViewController().present(vcMessages, animated: true, completion: nil)
        }
        else
        {
            alert("Messaging is unavailable.")
        }
    }
    
    @objc func messageComposeViewController(_ didFinishWithcontroller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        getTopViewController().dismiss(animated: true, completion: nil)
    }
    
    func shareFacebook(type: MuteShareDisplay.ShareType, level: LevelProtocol?, duration: Int) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
            let vcFacebook = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
     
            if vcFacebook != nil {
                vcFacebook!.add(URL(string: "https://itunes.apple.com/us/app/id1096009046"))
                getTopViewController().present(vcFacebook!, animated: true, completion: nil)
            }
        } else {
            alert("Please log into Facebook in the device Settings.")
        }
    }
    
    func shareTwitter(type: MuteShareDisplay.ShareType, level: LevelProtocol?, duration: Int) {
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            // Initialize the default view controller for sharing the post.
            let vcTwitter = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
     
            if vcTwitter != nil {
                let text = "Check out Astro Maze in the App Store!\nhttps://itunes.apple.com/us/app/id1096009046 #AIPuzzle"
                vcTwitter!.setInitialText(text)
         
    //            // Set the note text as the default post message.
    //            if count(self.noteTextview.text) <= 140 {
    //                twitterComposeVC.setInitialText("\(self.noteTextview.text)")
    //            }
    //            else {
    //                let index = advance(self.noteTextview.text.startIndex, 140)
    //                let subText = self.noteTextview.text.substringToIndex(index)
    //                twitterComposeVC.setInitialText("\(subText)")
    //            }
         
                getTopViewController().present(vcTwitter!, animated: true, completion: nil)
            }
        }
        else {
            alert("Please log into Twitter in the device Settings.")
        }
    }
    
    func alert(_ message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
        getTopViewController().present(alertController, animated: true, completion: nil)
    }
    
    func creationCancelWarning(scene: CreationScene) {
        let alertController = UIAlertController(title: nil, message: "All changes will be discarded.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Keep", style: UIAlertActionStyle.default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Discard", style: UIAlertActionStyle.destructive, handler: { action -> Void in
            scene.cancelDone()
        }))
        getTopViewController().present(alertController, animated: true, completion: nil)
    }
    
    func creationFinishWarning(scene: CreationScene, numSolutions: Int, name: String) {
        var msg = "Your puzzle contains \(numSolutions) unique solution"
        if numSolutions != 1 {
            msg += "s"
        }
        msg += "."
        
        var nameField: UITextField? = nil
        let alertController = UIAlertController(title: nil, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField(configurationHandler: { textField -> Void in
            textField.placeholder = "Name"
            textField.text = name
            nameField = textField
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Finish", style: UIAlertActionStyle.default, handler: { action -> Void in
            var name = "My Puzzle"
            if nameField != nil && !nameField!.text!.isEmpty {
                name = nameField!.text!
            }
            scene.finishDone(name: name)
        }))
        getTopViewController().present(alertController, animated: true, completion: nil)
    }

}
