//
//  RearListVc.swift
//  cpasbien
//
//  Created by David Tisserand on 27/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import UIKit

class RearListVc: UITableViewController {
    @IBOutlet weak var outletCellHome: RearListVcCell!
    @IBOutlet weak var outletCellSyno: RearListVcCell!
    @IBOutlet weak var outletCellCpasbien: RearListVcCell!
    
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
            let frontVc = self.revealViewController().frontViewController
            var newFrontNav: UINavigationController? = nil
            if let nav = frontVc as? UINavigationController {
                var sameVc = false
                if cell == outletCellHome {
                    sameVc = nav.topViewController is HomeVc
                    newFrontNav = MainObject.shared.storyBoardMain.instantiateViewControllerWithIdentifier("navHomeVcId") as UINavigationController?
                }
                else if cell == outletCellSyno {
                    sameVc = nav.topViewController is SynoVc
                    newFrontNav = MainObject.shared.storyBoardMain.instantiateViewControllerWithIdentifier("navSynoVcId") as UINavigationController?
                }
                else if cell == outletCellCpasbien {
                    sameVc = nav.topViewController is SearchListVc
                    newFrontNav = MainObject.shared.storyBoardMain.instantiateViewControllerWithIdentifier("navSearchListVcId") as UINavigationController?
                }
                
                if sameVc {
                    newFrontNav = nav
                }
                self.revealViewController().pushFrontViewController(newFrontNav!, animated: true)
            }
        }
    }

}
