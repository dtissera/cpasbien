//
//  TorrentListVc.swift
//  cpasbien
//
//  Created by David Tisserand on 25/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import UIKit
import SwiftyJSON
import REMenu
import CocoaLumberjack
import DTIToastCenter
import SwiftTask
import KVNProgress

protocol TorrentListVcDelegate: NSObjectProtocol {
    func torrentListDidChanged(sender: TorrentListVc)
}

class TorrentListVc: UITableViewController, UIActionSheetDelegate {
    @IBOutlet weak var outletLabelNbTorrents: UILabel!
    @IBOutlet weak var outletLabelMissingDownloads: UILabel!
    @IBOutlet weak var outletLabelAdded: UILabel!
    @IBOutlet weak var outletLabelModified: UILabel!
    @IBOutlet weak var outletLabelId: UILabel!

    private var searchItem: SearchItem? {
        didSet {
            updateView()
        }
    }

    private var data: Array<TorrentItem>?
    private var menu: REMenu?

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
    
    var delegate: TorrentListVcDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        let image = UIImage(named: "ellipsis")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.Bordered, target: self, action: Selector("displayMenu:"))
        
        self.outletLabelMissingDownloads.textColor = UIColor.redColor()
        self.updateView()
        
        // hide empty cell at table bottom
        self.tableView.tableFooterView = UIView(frame: CGRectZero)

        // Menu
        self.configureMenu()
        
        self.load()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        if let m = self.menu {
            if m.isOpen {
                m.close()
            }
        }

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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TorrentListVcCellIdentifier", forIndexPath: indexPath) as? TorrentListVcCell
        cell!.configure(item: item)
        return cell!
    }

    // -------------------------------------------------------------------------
    // MARK: - UITableViewDelegate
    // -------------------------------------------------------------------------
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = self.data![indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if (self.isLoading) {
            DTIToastCenter.defaultCenter.makeText("try later ! task in progress")
            return
        }
        
        if let enabled = item.enabled {
            var caption: String!
            if enabled {
                caption = "disable"
            }
            else {
                caption = "enable"
            }
            let popup = UIActionSheet(title: item.name, delegate: self, cancelButtonTitle: "cancel", destructiveButtonTitle: nil, otherButtonTitles: caption)
            popup.tag = indexPath.row
            popup.showInView(self.view)
        }
    }

    // -------------------------------------------------------------------------
    // MARK: - UIActionSheetDelegate
    // -------------------------------------------------------------------------
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        let item = self.data![actionSheet.tag]
        println(buttonIndex)
        
        switch buttonIndex {
        case 0: //cancel
            DDLog.logVerbose("cancel")
        case 1: // enable/disable
            if let enabled = item.enabled {
                var caption: String!
                if enabled {
                    DDLog.logVerbose("disable")
                    if let order = item.order {
                        self.disable(order)
                    }
                }
                else {
                    DDLog.logVerbose("enable")
                    if let order = item.order {
                        self.enable(order)
                    }
                }
            }
        default:
            DDLog.logVerbose("not implemented")
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - private methods
    // -------------------------------------------------------------------------
    private func updateView() {
        if !self.isViewLoaded() {
            return
        }
        self.title = "?"
        outletLabelNbTorrents.text = ""
        outletLabelMissingDownloads.text = ""
        outletLabelAdded.text = ""
        outletLabelModified.text = ""
        outletLabelId.text = ""
        if let itemObject = searchItem {
            if let text = itemObject.id {
                outletLabelId.text = text
            }
            if let text = itemObject.research {
                self.title = text
            }
            if let count = itemObject.count {
                outletLabelNbTorrents.text = "\(count) torrent(s)"
            }
            if let count = itemObject.missingCount {
                if count > 0 {
                    outletLabelMissingDownloads.text = "\(count)"
                }
            }
            if let date = itemObject.added {
                outletLabelAdded.text = "Added: \(date.toString())"
            }
            if let date = itemObject.updated {
                outletLabelModified.text = "Modified: \(date.toString())"
            }
        }
        self.tableView.reloadData()
    }

    private func configureMenu() {
        let itemScrap = REMenuItem(title: "scrap torrents", image: nil, highlightedImage: nil, action: { (menuItem: REMenuItem!) -> Void in
            self.scrap()
        })
        let itemDowbloadTorrents = REMenuItem(title: "download missing torrents (enabled)", image: nil, highlightedImage: nil, action: { (menuItem: REMenuItem!) -> Void in
            self.downloadAll()
        })
        let itemDisableTorrents = REMenuItem(title: "disable all torrents", image: nil, highlightedImage: nil, action: { (menuItem: REMenuItem!) -> Void in
            self.disableAll()
        })
        let itemEnableTorrents = REMenuItem(title: "enable all torrents", image: nil, highlightedImage: nil, action: { (menuItem: REMenuItem!) -> Void in
            self.enableAll()
        })
    
        self.menu = REMenu(items: [itemScrap, itemDowbloadTorrents, itemDisableTorrents, itemEnableTorrents])
        if let m = self.menu {
            m.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 17.0)
        }
    }
    
    private func restAction(request: NSURLRequest) {
        if self.isLoading {
            return
        }
        
        if let ident = self.searchItem?.id {
            self.isLoading = true
            KVNProgress.showWithStatus("Loading ...")
            
            let task = Connect.shared.promiseTask(request)
            task.success { value -> Void in
                self.loadTaskData(value) { (searchItem, data) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.searchItem = searchItem
                        self.data = data
                        self.updateView()
                        
                        if let d = self.delegate {
                            d.torrentListDidChanged(self)
                        }
                        
                        self.isLoading = false
                        KVNProgress.dismiss()
                    })
                }
                }.failure { error, isCancelled -> Void in
                    if let err = error {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            DTIToastCenter.defaultCenter.makeText(err.localizedDescription)
                            self.isLoading = false
                            KVNProgress.dismiss()
                        })
                    }
                }
        }
    }
    
    private func scrap() {
        DDLog.logVerbose("...")
        if self.isLoading {
            return
        }
        
        if let ident = self.searchItem?.id {
            self.restAction(Request.researchUpdate(ident))
        }
    }
    
    private func disableAll() {
        DDLog.logVerbose("...")
        if self.isLoading {
            return
        }
        
        if let ident = self.searchItem?.id {
            self.restAction(Request.researchDisable(ident, order: nil))
        }
    }
    
    private func disable(order: Int) {
        DDLog.logInfo("order=\(order)")
        if self.isLoading {
            return
        }
        
        if let ident = self.searchItem?.id {
            self.restAction(Request.researchDisable(ident, order: order))
        }
    }
    
    private func enableAll() {
        DDLog.logVerbose("...")
        if self.isLoading {
            return
        }
        
        if let ident = self.searchItem?.id {
            self.restAction(Request.researchEnable(ident, order: nil))
        }
    }

    private func enable(order: Int) {
        DDLog.logInfo("order=\(order)")
        if self.isLoading {
            return
        }
        
        if let ident = self.searchItem?.id {
            self.restAction(Request.researchEnable(ident, order: order))
        }
    }

    private func downloadAll() {
        DDLog.logInfo("...")
        if self.isLoading {
            return
        }
        
        if let ident = self.searchItem?.id {
            self.restAction(Request.researchDownload(ident))
        }
    }
    
    private func loadTaskData(jsonData: JSON, closure: (searchItem: SearchItem, data: Array<TorrentItem>) -> Void) {
        var taskData = Array<TorrentItem>()
        var taskItem = SearchItem(json: jsonData)
        
        if let json = jsonData.dictionary?["torrents"] {
            for (index: String, object: JSON) in json {
                let item = TorrentItem(json: object)
                
                taskData.append(item)
            }
        }
        
        closure(searchItem: taskItem, data: taskData)
    }
    
    private func load() {
        DDLog.logVerbose("...")
        if self.isLoading {
            return
        }
        
        if let ident = self.searchItem?.id {
            self.isLoading = true

            KVNProgress.showWithStatus("Loading ...")
            var request: NSURLRequest = Request.research(ident)
            
            let task = Connect.shared.promiseTask(request)
            task.success { value -> Void in
                self.loadTaskData(value) { (searchItem, data) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.searchItem = searchItem
                        self.data = data
                        self.updateView()
                        
                        self.isLoading = false
                        KVNProgress.dismiss()
                    })
                }
            }.failure { error, isCancelled -> Void in
                if let err = error {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        DTIToastCenter.defaultCenter.makeText(err.localizedDescription)
                        self.isLoading = false
                        KVNProgress.dismiss()
                    })
                }
            }
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - public methods
    // -------------------------------------------------------------------------
    func configure(#item: SearchItem) {
        self.searchItem = item
    }

    func displayMenu(sender: AnyObject) {
        if let m = self.menu {
            if m.isOpen {
                m.close()
            }
            m.showFromNavigationController(self.navigationController!)
        }
    }

}
