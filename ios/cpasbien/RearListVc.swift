//
//  RearListVc.swift
//  cpasbien
//
//  Created by David Tisserand on 27/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import UIKit
import CocoaLumberjack

class RearListVc: UITableViewController {
    @IBOutlet weak var outletCellHome: RearListVcCell!
    @IBOutlet weak var outletCellSyno: RearListVcCell!
    @IBOutlet weak var outletCellCpasbien: RearListVcCell!
    
    deinit {
        DDLog.logDebug("~ctor")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // hide empty cell at table bottom
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.tableView.backgroundColor = UIColor(rgba: MainObject.Consts.REARVC_BG_COLOR)
    }

    // -------------------------------------------------------------------------
    // MARK: - UITableViewDelegate
    // -------------------------------------------------------------------------
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            DDLog.logDebug(String(format: "cell: %@", cell.reuseIdentifier ?? "?"))
            
            let frontVc = self.revealViewController().frontViewController
            var newFrontNav: UINavigationController!
            if let nav = frontVc as? UINavigationController {
                var sameVc = false
                var newFrontNavIdentifier: String!
                
                DDLog.logDebug(String(format: "topViewController: %@", NSStringFromClass(nav.topViewController.classForCoder)))
                if cell == outletCellHome {
                    sameVc = nav.topViewController is HomeVc
                    newFrontNavIdentifier = "navHomeVcId"
                }
                else if cell == outletCellSyno {
                    sameVc = nav.topViewController is SynoVc
                    newFrontNavIdentifier = "navSynoVcId"
                }
                else if cell == outletCellCpasbien {
                    sameVc = nav.topViewController is SearchListVc
                    newFrontNavIdentifier = "navSearchListVcId"
                }
                
                if sameVc {
                    newFrontNav = nav
                }
                else {
                    newFrontNav = MainObject.shared.storyBoardMain.instantiateViewControllerWithIdentifier(newFrontNavIdentifier) as UINavigationController
                    
                }
                
                self.revealViewController().pushFrontViewController(newFrontNav, animated: true)
            }
        }
    }

}
