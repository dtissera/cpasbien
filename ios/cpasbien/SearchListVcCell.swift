//
//  SearchListVcCell.swift
//  cpasbien
//
//  Created by David Tisserand on 22/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import UIKit

class SearchListVcCell: UITableViewCell {
    
    private var item: SearchItem? {
        didSet {
            updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textLabel!.textColor = UIColor.blackColor()
        self.detailTextLabel!.textColor = UIColor(rgba: MainObject.Consts.DARK_TEXT)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.item = nil
    }
    
    func updateView() {
        self.textLabel!.text = ""
        self.detailTextLabel!.text = ""
        if let itemObject = item {
            if let text = itemObject.research {
                var cellText = text
                if let count = itemObject.missingCount {
                    if count > 0 {
                        cellText = "\(text) [\(count)]"
                    }
                }
                self.textLabel!.text = cellText
            }
            if let count = itemObject.count {
                self.detailTextLabel!.text = "\(count) torrent"
                if count > 1 {
                    self.detailTextLabel!.text! += "s"
                }
            }
            if let date = itemObject.updated {
                self.detailTextLabel!.text! += " - \(NSDate.sharedWriteDateFormatter.stringFromDate(date))"
            }
        }
    }
    
    func configure(#item: SearchItem) {
        self.item = item
    }
}
