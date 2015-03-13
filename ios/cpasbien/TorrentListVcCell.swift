//
//  TorrentListVcCell.swift
//  cpasbien
//
//  Created by David Tisserand on 26/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import UIKit

class TorrentListVcCell: UITableViewCell {
    private var item: TorrentItem? {
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
            if let text = itemObject.name {
                self.textLabel!.text = text
            }
            var fileSize: String = "?"
            if let text = itemObject.fileSize {
                fileSize = text
            }

            var dateStr: String = "?"
            if let date = itemObject.date {
                dateStr = date.toString()
            }

            self.detailTextLabel!.text = "\(fileSize) - \(dateStr)"
            
            if let enabled = itemObject.enabled {
                self.textLabel!.textColor = enabled ? UIColor.blackColor() : UIColor.grayColor()
            }
        }
    }
    
    func configure(#item: TorrentItem) {
        self.item = item
    }

}
