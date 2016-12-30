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
        
        view.backgroundColor = UIColor.black
        
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
        navigationController!.navigationBar.barTintColor = UIColor.black
        navigationController!.navigationBar.tintColor = UIColor.white
        
        let backButton = UIBarButtonItem(title: "<", style: .plain, target: self, action: #selector(back))
        backButton.setTitleTextAttributes([
            NSFontAttributeName: font
            ], for: .normal)
        navigationItem.setLeftBarButton(backButton, animated: false)
        
        let addFont = UIFont(name: Constants.FONT, size: s * Constants.TEXT_SCALE * 2)!
        
        let addButton = UIBarButtonItem(title: "+", style: .plain, target: self, action: #selector(newLevel))
        addButton.setTitleTextAttributes([
            NSFontAttributeName: addFont
            ], for: .normal)
        navigationItem.setRightBarButton(addButton, animated: false)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _levelNames.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let w = view.frame.width
        let h = view.frame.height
        let s = min(w, h)
        
        let cell = UITableViewCell()

        cell.textLabel?.text = "\(_levelNames[indexPath.row])"
        cell.textLabel?.font = UIFont(name: Constants.FONT, size: s * Constants.TEXT_SCALE * 0.75)!
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = UIColor.black
        
        
        let selectionView = UIView()
        selectionView.backgroundColor = UIColor.gray
        cell.selectedBackgroundView = selectionView

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let code = Storage.loadCustomLevelCode(index: indexPath.row)
        let level = LevelParser.parse(code: code as String, allowCustom: true)
        if level != nil {
            DispatchQueue.main.async {
                let playScene = PlayScene(size: self.view.bounds.size, level: level!)
                playScene.scaleMode = .resizeFill
                AppDelegate.pushViewController(SKViewController(scene: playScene), animated: true, offset: 1)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [UITableViewRowAction(style: .default, title: "Delete", handler: {rowAction, indexPath in
                    Storage.deleteCustomLevel(index: indexPath.row)
                    self._levelNames = Storage.loadCustomLevelNames()
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }),
                UITableViewRowAction(style: .normal, title: "Edit", handler: {rowAction, indexPath in
                    let code = Storage.loadCustomLevelCode(index: indexPath.row)
                    let level = LevelParser.parse(code: code as String, allowCustom: true)
                    if level != nil {
                        DispatchQueue.main.async {
                            let creationScene = CreationScene(size: UIScreen.main.bounds.size, level: level!)
                            creationScene._editIndex = indexPath.row
                            creationScene.scaleMode = .resizeFill
                            AppDelegate.pushViewController(SKViewController(scene: creationScene), animated: true, offset: 1)
                        }
                    }
                })]
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
