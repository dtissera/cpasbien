//
//  RenameFileVc.swift
//  cpasbien
//
//  Created by David Tisserand on 15/03/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import UIKit
import CocoaLumberjack
import SwiftyJSON
import DTIToastCenter
import KVNProgress

protocol RenameFileVcDelegate: NSObjectProtocol {
    func renameFileVcDidSuccess(sender: RenameFileVc)
}

class RenameFileVc: UITableViewController {
    @IBOutlet weak var outletTextFieldName: UITextField!
    @IBOutlet weak var outletLabelDescription: UILabel!

    class FileItem {
        var path: String
        var name: String
        
        init(path: String, name: String) {
            self.path = path
            self.name = name
        }
    }
    
    var file: FileItem? {
        didSet {
            self.updateView()
        }
    }
    
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

    var delegate: RenameFileVcDelegate?
    
    deinit {
        DDLog.logDebug("~ctor")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Rename file"
        
        // hide empty cell at table bottom
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        outletLabelDescription.textColor = UIColor(rgba: MainObject.Consts.BAR_TINT_COLOR)
        outletTextFieldName.becomeFirstResponder()
        
        self.updateView()
    }

    // -------------------------------------------------------------------------
    // MARK: - @IBAction
    // -------------------------------------------------------------------------
    @IBAction func actionCancel(sender: AnyObject) {
        DDLog.logVerbose("...")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func actionValidate(sender: AnyObject) {
        DDLog.logVerbose("...")
        
        if self.isLoading {
            return
        }
        
        if let f = self.file {
            self.isLoading = true
            KVNProgress.showWithStatus("Renaming ...")
            
            let task = Connect.shared.promiseTask(Request.synoRename(f.path, name: self.outletTextFieldName.text))
            task.success { value -> Void in
                self.loadTaskData(value) { () -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in

                        if let d = self.delegate {
                            d.renameFileVcDidSuccess(self)
                        }
                        
                        self.isLoading = false
                        KVNProgress.dismiss()
                        
                        self.dismissViewControllerAnimated(true, completion: nil)
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
    // MARK: - private methods
    // -------------------------------------------------------------------------
    private func loadTaskData(jsonData: JSON, closure: () -> Void) {
        println(jsonData.rawString())
        /*
        if let json = jsonData["data"]["files"][0]["path"] {
            DDLog.logInfo("path: "+(json.string ?? "?"))
        }*/
        
        closure()
    }

    private func updateView() {
        if !self.isViewLoaded() {
            return
        }
        
        self.outletTextFieldName.text = file?.name ?? ""
    }

}
