//
//  SearchListVc.swift
//  cpasbien
//
//  Created by David Tisserand on 22/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import UIKit
import SwiftyJSON
import INSPullToRefresh
import DTIToastCenter
import CocoaLumberjack
import KVNProgress

class SearchListVc: UITableViewController, NewSearchVcDelegate, TorrentListVcDelegate {
    private var data: Array<SearchItem>?
    private var isLoading = false
    private var notifRefresh: NSObjectProtocol?
    
    deinit {
        DDLog.logDebug("~ctor")
        self.tableView.ins_removePullToRefresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "cpasbien"
        
        self.reavel_setup()
        
        // hide empty cell at table bottom
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.allowsMultipleSelectionDuringEditing = false
        
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
    }

    
    // -------------------------------------------------------------------------
    // MARK: - UITableViewDataSource
    // -------------------------------------------------------------------------
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let d = self.data {
            return d.count
        }
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let item = self.data![indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchListVcCellIdentifier", forIndexPath: indexPath) as? SearchListVcCell
        cell!.configure(item: item)
        return cell!
    }
    
    // -------------------------------------------------------------------------
    // MARK: - UITableViewDelegate
    // -------------------------------------------------------------------------
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let item = self.data!.removeAtIndex(indexPath.row) as SearchItem
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
            if let ident = item.id {
                var request: NSURLRequest = Request.researchDelete(ident)
                let task = Connect.shared.buildTask(request, completionHandler: { (result: FailableOf<JSON>) -> Void in
                    var taskData = Array<SearchItem>()
                    if (!result.failed) {
                        if let res = result.value?.rawString(encoding: NSUTF8StringEncoding, options: NSJSONWritingOptions.allZeros) {
                            DDLog.logInfo(res)
                        }
                    }
                    else {
                        if let err = result.error {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                DTIToastCenter.defaultCenter.makeText(err.localizedDescription)
                            })
                        }
                    }
                })
                task.resume()
            }
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - Navigation
    // -------------------------------------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? TorrentListVc {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let item = self.data![indexPath.row]
                vc.delegate = self
                vc.configure(item: item)
            }
        }
        //segueNavNewSearchId
        if let identifier = segue.identifier {
            if identifier == "segueNavNewSearchId" {
                if let nav = segue.destinationViewController as? UINavigationController {
                    if let vc = nav.topViewController as? NewSearchVc {
                        vc.delegate = self
                    }
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - NewSearchVcDelegate
    // -------------------------------------------------------------------------
    func newSearchSuccess(sender: NewSearchVc) {
        // Dispose of any resources that can be recreated.
        self.tableView.ins_beginPullToRefresh()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - TorrentListVcDelegate
    // -------------------------------------------------------------------------
    func torrentListDidChanged(sender: TorrentListVc) {
        // Dispose of any resources that can be recreated.
        self.tableView.ins_beginPullToRefresh()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - private methods
    // -------------------------------------------------------------------------
    private func dataLoad(completion: (() -> Void)?) {
        if self.isLoading {
            return
        }
        self.isLoading = true
        
        KVNProgress.showWithStatus("Loading ...")
        
        var request: NSURLRequest = Request.researchAll()
        let task = Connect.shared.buildTask(request, completionHandler: { (result: FailableOf<JSON>) -> Void in
            var taskData = Array<SearchItem>()
            if (!result.failed) {
                if let json = result.value {
                    for (index: String, object: JSON) in json {
                        let item = SearchItem(json: object)
                        
                        taskData.append(item)
                    }
                }
            }
            else {
                if let err = result.error {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        DTIToastCenter.defaultCenter.makeText(err.localizedDescription)
                    })
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.isLoading = false
                
                self.data = taskData
                self.tableView.reloadData()
                if completion != nil {
                    completion!()
                }
                KVNProgress.dismiss()
            })
        })
        task.resume()
    }
}
