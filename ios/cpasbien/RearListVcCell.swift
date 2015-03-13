//
//  RearListVcCell.swift
//  cpasbien
//
//  Created by David Tisserand on 28/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import UIKit

class RearListVcCell: UITableViewCell {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor(rgba: MainObject.Consts.REARVC_BG_COLOR)
        let bgView = UIView()
        bgView.backgroundColor = self.backgroundColor!.lighterColor()
        self.selectedBackgroundView = bgView
    }
}
