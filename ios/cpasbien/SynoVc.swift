//
//  SynoVc.swift
//  cpasbien
//
//  Created by David Tisserand on 01/03/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import UIKit
import SwiftyJSON
import CocoaLumberjack
import DTIToastCenter
import SwiftTask

class SynoVc: UITableViewController {
    @IBOutlet weak var outletCellCheck: UITableViewCell!

    private var isLoading = false
    
    deinit {
        DDLog.logDebug("~ctor")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "synology"
        self.reavel_setup()

        self.outletCellCheck.detailTextLabel!.text = ""
        
        // hide empty cell at table bottom
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - private methods
    // -------------------------------------------------------------------------
    func checkSyno() {
        if self.isLoading {
            return
        }
        self.isLoading = true
        self.outletCellCheck.detailTextLabel!.text = "please wait ..."
        
        let task = Connect.shared.promiseTask(Request.synoCheck())
        task.success { value -> Void in
            if let sid = value["sid"].string {
                self.outletCellCheck.detailTextLabel!.text = "sid=\(sid)"
            }
            else {
                self.outletCellCheck.detailTextLabel!.text = "sid ???"
            }

            if let jsonString = value.rawString(encoding: NSUTF8StringEncoding, options: NSJSONWritingOptions.allZeros) {
                DDLog.logInfo(jsonString)
            }
        }.failure { error, isCancelled -> Void in
            if let err = error {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.outletCellCheck.detailTextLabel!.text = err.localizedDescription
                    DTIToastCenter.defaultCenter.makeText(err.localizedDescription)
                })
            }
        }.then { value, errorInfo -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.isLoading = false
            })
        }

    }

    // -------------------------------------------------------------------------
    // MARK: - UITableViewDelegate
    // -------------------------------------------------------------------------
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell == self.outletCellCheck {
                self.checkSyno()
            }
        }
    }

}
