//
//  MyPuzzlesController.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 4/4/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import UIKit

class MyPuzzlesController: UITableViewController {

    var _levelNames: [NSString]! = nil

    override func loadView() {
        super.loadView()
    
        _levelNames = Storage.loadCustomLevelNames()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.blackColor()
        
        // Navigation Bar
        navigationController!.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName:UIColor.whiteColor()
        ]
        navigationController!.navigationBar.barTintColor = UIColor.blackColor()
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        let backButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "back:")
        navigationItem.setLeftBarButtonItem(backButton, animated: false)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "newLevel:")
        navigationItem.setRightBarButtonItem(addButton, animated: false)
        
//        // Toolbar
//        navigationController!.toolbar.barTintColor = UIColor.blackColor()
//        navigationController!.toolbar.tintColor = UIColor.whiteColor()
//        
//        // T O D O change action
//        setToolbarItems([
//            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "share:")
//        ], animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
//        navigationController!.setToolbarHidden(false, animated: true)
        navigationController!.setNavigationBarHidden(false, animated: true)
        navigationController!.navigationBar.topItem?.title = "My Puzzles"
    }
    
    func back(sender: UIBarButtonItem) {
        navigationController!.popToRootViewControllerAnimated(true)
    }
    
    func newLevel(sender: UIBarButtonItem) {
        navigationController!.pushViewController(SKViewController(scene: CustomLevelSelectScene()), animated: true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _levelNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()

        cell.textLabel?.text = "\(_levelNames[indexPath.row])"
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.backgroundColor = UIColor.blackColor()
        
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor.grayColor()
        cell.selectedBackgroundView = selectionView

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let code = Storage.loadCustomLevelCode(indexPath.row)
        let level = LevelParser.parse(code as String, allowCustom: true)
        if level != nil {
            dispatch_async(dispatch_get_main_queue()) {
                let playScene = PlayScene(size: self.view.bounds.size, level: level!)
                playScene.scaleMode = .ResizeFill
                (UIApplication.sharedApplication().delegate! as! AppDelegate).pushViewController(SKViewController(scene: playScene), animated: true)
            }
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        // TODO make these buttons do something
        return [UITableViewRowAction.init(style: .Default, title: "Delete", handler: {_,_ in }),
                UITableViewRowAction.init(style: .Normal, title: "Edit", handler: {_,_ in })]
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
