//
//  HomeVc.swift
//  cpasbien
//
//  Created by David Tisserand on 28/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import UIKit
import TOMSMorphingLabel
import CocoaLumberjack
import SwiftyJSON
import DTIToastCenter

class HomeVc: UITableViewController {
    @IBOutlet weak var outletMorphingLabel: TOMSMorphingLabel!
    @IBOutlet weak var outletCellVersion: UITableViewCell!
    @IBOutlet weak var outletCellApi: UITableViewCell!
    @IBOutlet weak var outletCellCheckApi: UITableViewCell!

    private let textValues: Array<String> = ["", "Welcome", "to", "cpasbien"]
    
    private var _idx: Int = 0
    private var idx: Int {
        get {
            return _idx
        }
        set(newValue) {
            _idx = max(0, min(newValue, newValue % textValues.count))
        }
    }
    
    private var isCheckingApi = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "DEMO NodeJs scraping"
        self.reavel_setup()
        
        self.outletMorphingLabel.textColor = UIColor(rgba: MainObject.Consts.BAR_TINT_COLOR)

        // hide empty cell at table bottom
        self.tableView.tableFooterView = UIView(frame: CGRectZero)

        // Data
        let version = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as String
        outletCellVersion.detailTextLabel!.text = version
        
        let rest = Request.RestUrlFactory()
        outletCellApi.detailTextLabel!.text = rest.toUrl().description
        
        // Check API
        self.checkApi()
        
        // Anim
        toggleText()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - UITableViewDelegate
    // -------------------------------------------------------------------------
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell == self.outletCellCheckApi {
                self.checkApi()
            }
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - private methods
    // -------------------------------------------------------------------------
    private func checkApi() {
        if self.isCheckingApi {
            return
        }
        self.isCheckingApi = true
        
        let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.outletCellCheckApi.accessoryView = activityView
        activityView.startAnimating()
        
        let updCellFct = {(text: String, removeActivity: Bool) -> Void in
            self.outletCellCheckApi.detailTextLabel!.text = text
            // Fix IOS 8 bug
            let style = self.outletCellCheckApi.selectionStyle
            self.outletCellCheckApi.selectionStyle = UITableViewCellSelectionStyle.None
            self.outletCellCheckApi.selected = true
            self.outletCellCheckApi.selected = false
            self.outletCellCheckApi.selectionStyle = style
            if removeActivity {
                activityView.stopAnimating()
                self.outletCellCheckApi.accessoryView = nil
            }
        }
        
        updCellFct("", false)
        
        var request: NSURLRequest = Request.ping()
        let task = Connect.shared.buildTask(request, completionHandler: { (result: FailableOf<JSON>) -> Void in
            var taskData = Array<SearchItem>()
            if (!result.failed) {
                if let message = result.value?["message"].string {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        Tools.delay(1, closure: { () -> () in
                            updCellFct(message, true)
                        })
                    })
                }
            }
            else {
                if let err = result.error {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        updCellFct(err.localizedDescription, true)
                    })
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.isCheckingApi = false
            })
        })
        task.resume()

    }

    // -------------------------------------------------------------------------
    // MARK: - public methods
    // -------------------------------------------------------------------------
    func toggleText() {
        self.outletMorphingLabel.text = textValues[idx++]
        
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(2), target: self, selector: Selector("toggleText"), userInfo: nil, repeats: false)
    }

}
