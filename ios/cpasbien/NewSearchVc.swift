//
//  NewSearchVc.swift
//  cpasbien
//
//  Created by David Tisserand on 28/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import UIKit
import CocoaLumberjack
import SwiftyJSON
import DTIToastCenter
import KVNProgress

protocol NewSearchVcDelegate: NSObjectProtocol {
    func newSearchSuccess(sender: NewSearchVc)
}

class NewSearchVc: UITableViewController {
    @IBOutlet weak var outletTextFieldSearch: UITextField!
    @IBOutlet weak var outletLabelDescription: UILabel!

    var delegate: NewSearchVcDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.title = "Add new research"

        // hide empty cell at table bottom
        self.tableView.tableFooterView = UIView(frame: CGRectZero)

        outletLabelDescription.textColor = UIColor(rgba: MainObject.Consts.BAR_TINT_COLOR)
        outletTextFieldSearch.becomeFirstResponder()
    }

    @IBAction func actionCancel(sender: AnyObject) {
        DDLog.logVerbose("...")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func actionValidate(sender: AnyObject) {
        DDLog.logVerbose("...")
        
        var search: String = outletTextFieldSearch.text
        search = search.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        if (search.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0) {
            return
        }
        
        KVNProgress.showWithStatus("Saving ...")
        
        var request: NSURLRequest = Request.researchCreate(search)
        let task = Connect.shared.buildTask(request, completionHandler: { (result: FailableOf<JSON>) -> Void in
            var taskData = Array<SearchItem>()
            if (!result.failed) {
                if let res = result.value?.rawString(encoding: NSUTF8StringEncoding, options: NSJSONWritingOptions.allZeros) {
                    DDLog.logInfo(res)
                }
                //println(result.value)
                if let del = self.delegate {
                    del.newSearchSuccess(self)
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                if let err = result.error {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        DTIToastCenter.defaultCenter.makeText(err.localizedDescription)
                    })
                }
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                KVNProgress.dismiss()
                //self.isLoading = false
                
                //self.data = taskData
            })
        })
        task.resume()

    }
}
