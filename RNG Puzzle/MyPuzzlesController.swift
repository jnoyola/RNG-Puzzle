//
//  MyPuzzlesController.swift
//  AI Puzzle
//
//  Created by Jonathan Noyola on 4/4/16.
//  Copyright © 2016 iNoyola. All rights reserved.
//

import UIKit

class MyPuzzlesController: UITableViewController, Refreshable {

    var _levelNames: [NSString]! = nil

    override func loadView() {
        super.loadView()
    
        _levelNames = Storage.loadCustomLevelNames()
    }
    
    func refresh() {
        _levelNames = Storage.loadCustomLevelNames()
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.blackColor()
        
        let w = view.frame.width
        let h = view.frame.height
        let s = min(w, h)
        
        let font = UIFont(name: Constants.FONT, size: s * Constants.TITLE_SCALE)!
        
        // Navigation Bar
        navigationController!.navigationBar.frame.origin.y = 100
        
        navigationController!.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: Constants.TITLE_COLOR,
            NSFontAttributeName: font
        ]
        navigationController!.navigationBar.barTintColor = UIColor.blackColor()
        navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        let backButton = UIBarButtonItem(title: "<", style: .Plain, target: self, action: #selector(back))
        backButton.setTitleTextAttributes([
            NSFontAttributeName: font
        ], forState: .Normal)
        navigationItem.setLeftBarButtonItem(backButton, animated: false)
        
        let addFont = UIFont(name: Constants.FONT, size: s * Constants.TEXT_SCALE * 2)!
        
        let addButton = UIBarButtonItem(title: "+", style: .Plain, target: self, action: #selector(newLevel))
        addButton.setTitleTextAttributes([
            NSFontAttributeName: addFont
        ], forState: .Normal)
        navigationItem.setRightBarButtonItem(addButton, animated: false)
        
//        // Toolbar
//        navigationController!.toolbar.barTintColor = UIColor.blackColor()
//        navigationController!.toolbar.tintColor = UIColor.whiteColor()
//        
//        // T O D O change action
//        setToolbarItems([
//            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "share:")
//        ], animated: false)

        tableView.rowHeight = s * Constants.TEXT_SCALE * 1.5
    }
    
    override func viewWillAppear(animated: Bool) {
//        navigationController!.setToolbarHidden(false, animated: true)
        navigationController!.setNavigationBarHidden(false, animated: true)
        navigationController!.navigationBar.topItem?.title = "My Puzzles"
    }
    
    func back(sender: UIBarButtonItem) {
        AppDelegate.popViewController(animated: true)
    }
    
    func newLevel(sender: UIBarButtonItem) {
        AppDelegate.pushViewController(SKViewController(scene: CustomLevelSelectScene()), animated: true, offset: 1)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _levelNames.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let w = view.frame.width
        let h = view.frame.height
        let s = min(w, h)
        
        let cell = UITableViewCell()

        cell.textLabel?.text = "\(_levelNames[indexPath.row])"
        cell.textLabel?.font = UIFont(name: Constants.FONT, size: s * Constants.TEXT_SCALE * 0.75)!
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
                AppDelegate.pushViewController(SKViewController(scene: playScene), animated: true, offset: 1)
            }
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .Default, title: "Delete", handler: {rowAction, indexPath in
                    Storage.deleteCustomLevel(indexPath.row)
                    self._levelNames = Storage.loadCustomLevelNames()
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                }),
                UITableViewRowAction(style: .Normal, title: "Edit", handler: {rowAction, indexPath in
                    let code = Storage.loadCustomLevelCode(indexPath.row)
                    let level = LevelParser.parse(code as String, allowCustom: true)
                    if level != nil {
                        dispatch_async(dispatch_get_main_queue()) {
                            let creationScene = CreationScene(size: UIScreen.mainScreen().bounds.size, level: level!)
                            creationScene._editIndex = indexPath.row
                            creationScene.scaleMode = .ResizeFill
                            AppDelegate.pushViewController(SKViewController(scene: creationScene), animated: true, offset: 1)
                        }
                    }
                })]
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
