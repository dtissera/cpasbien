//
//  DownloadsVc.swift
//  cpasbien
//
//  Created by David Tisserand on 15/03/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import UIKit
import SwiftyJSON
import CocoaLumberjack
import DTIToastCenter
import SwiftTask
import KVNProgress

class DownloadsVc: UITableViewController, RenameFileVcDelegate, UIActionSheetDelegate {

    private var isLoading_ = false
    private var isLoading: Bool {
        get {
            var read: Bool!
            Tools.sync(self) {
                read = self.isLoading_
            }
            return read
        }
        set {
            Tools.sync(self) {
                self.isLoading_ = newValue
            }
        }
    }

    private var pathItem: SynoPathItem?
    private var paths = Array<String>()
    
    deinit {
        DDLog.logDebug("~ctor")
        self.tableView.ins_removePullToRefresh()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // remove rows separator for empty cells
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.updateView()
        
        self.tableView.ins_addPullToRefreshWithHeight(60.0, handler: { (sv: UIScrollView!) -> Void in
            if self.isLoading {
                return
            }
            self.dataLoad({ () -> Void in
                sv.ins_endPullToRefresh()
            })
        })
        
        let pullToRefresh = PullToRefreshView(frame: CGRect(x: 0.0, y: 0.0, width: 25.0, height: 25.0))
        
        self.tableView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh
        self.tableView.ins_pullToRefreshBackgroundView.addSubview(pullToRefresh)
        
        // Load
        self.tableView.ins_beginPullToRefresh()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // -------------------------------------------------------------------------
    // MARK: - UITableViewControllerDataSource
    // -------------------------------------------------------------------------
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let path = self.pathItem {
            return path.files.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DownloadsVcCellId", forIndexPath: indexPath) as DownloadsVcCell
        
        if let file = self.pathItem?.files[indexPath.row] {
            cell.item = file
        }

        return cell
    }

    // -------------------------------------------------------------------------
    // MARK: - UITableViewControllerDelegate
    // -------------------------------------------------------------------------
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        if let file = self.pathItem?.files[indexPath.row] {
            if let name = file.name {
                if file.isdir ?? false {
                    if name != ".." {
                        paths.append(name)
                    }
                    else {
                        paths.removeLast()
                    }
                    
                    self.tableView.ins_beginPullToRefresh()
                }
                else {
                    let popup = UIActionSheet(title: name, delegate: self, cancelButtonTitle: "cancel", destructiveButtonTitle: nil, otherButtonTitles: "rename", "move")
                    popup.tag = indexPath.row
                    popup.showInView(self.view)
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - UIActionSheetDelegate
    // -------------------------------------------------------------------------
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if let file = self.pathItem?.files[actionSheet.tag] {
            DDLog.logDebug("buttonIndex: \(buttonIndex)")
            
            switch buttonIndex {
            case 0: //cancel
                DDLog.logVerbose("cancel")
            case 1: // rename
                DDLog.logVerbose("rename")
                
                if let nav = MainObject.shared.storyBoardMain.instantiateViewControllerWithIdentifier("navRenameFileVc") as? UINavigationController {
                    if let vc = nav.topViewController as? RenameFileVc {
                        var path = "/" + (file.name ?? "")
                        if self.paths.count > 0 {
                            path = "/" + join("/", self.paths) + path
                        }
                        vc.delegate = self
                        vc.file = RenameFileVc.FileItem(path: path, name: file.name ?? "")
                    }
                    self.presentViewController(nav, animated: true, completion: nil)
                }
            case 2: // move
                DDLog.logVerbose("rename")
                var path = "/" + (file.name ?? "")
                if self.paths.count > 0 {
                    path = "/" + join("/", self.paths) + path
                }
                self.moveFile(path)
            default:
                DDLog.logVerbose("not implemented")
            }
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - RenameFileVcDelegate
    // -------------------------------------------------------------------------
    func renameFileVcDidSuccess(sender: RenameFileVc) {
        self.tableView.ins_beginPullToRefresh()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - private methods
    // -------------------------------------------------------------------------
    private func updateView() {
        if !self.isViewLoaded() {
            return
        }
        self.title = self.paths.count == 0 ? "downloads" : self.paths.last
        
        self.tableView.reloadData()
    }
    
    private func loadTaskData(jsonData: JSON, closure: (pathItem: SynoPathItem) -> Void) {
        println(jsonData.rawString())
        var taskItem = SynoPathItem(json: jsonData, isRoot: self.paths.count == 0)
        closure(pathItem: taskItem)
    }

    func moveFile(path: String) {
        DDLog.logVerbose("...")
        
        if self.isLoading {
            return
        }
        
        self.isLoading = true
        KVNProgress.showWithStatus("Moving ...")
        
        let task = Connect.shared.promiseTask(Request.synoMove(path))
        task.success { value -> Void in
            println(value.rawString())
            self.isLoading = false
            KVNProgress.dismiss()
            
            self.tableView.ins_beginPullToRefresh()
        }.failure { error, isCancelled -> Void in
            if let err = error {
                DTIToastCenter.defaultCenter.makeText(err.localizedDescription)
                self.isLoading = false
                KVNProgress.dismiss()
            }
        }
        
    }

    private func dataLoad(completion: (() -> Void)?) {
        DDLog.logVerbose("...")
        if self.isLoading {
            return
        }
        
        var path = ""
        if self.paths.count > 0 {
            path = "/" + join("/", self.paths)
        }

        self.isLoading = true
            
        var request: NSURLRequest = Request.synoList(path)
        
        let task = Connect.shared.promiseTask(request)
        task.success { value -> Void in
            self.loadTaskData(value) { (pathItem) -> Void in
                self.pathItem = pathItem
                self.updateView()
                
                self.isLoading = false
                if completion != nil {
                    completion!()
                }
            }
        }.failure { error, isCancelled -> Void in
            if let err = error {
                DTIToastCenter.defaultCenter.makeText(err.localizedDescription)
                
                self.isLoading = false
                if completion != nil {
                    completion!()
                }
            }
        }
    }
}
