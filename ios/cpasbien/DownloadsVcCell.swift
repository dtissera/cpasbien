//
//  DownloadsVcCell.swift
//  cpasbien
//
//  Created by David Tisserand on 15/03/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import UIKit

class DownloadsVcCell: UITableViewCell {

    var item: SynoPathItem.FileItem? {
        didSet {
            updateView()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textLabel!.textColor = UIColor(rgba: MainObject.Consts.DARK_TEXT)
        self.tintColor = UIColor(rgba: MainObject.Consts.BAR_TINT_COLOR)
        self.imageView!.tintColor == UIColor(rgba: MainObject.Consts.BAR_TINT_COLOR)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.item = nil
    }

    func updateView() {
        self.textLabel!.text = ""
        self.imageView?.image = nil
        self.accessoryType = UITableViewCellAccessoryType.None
        if let itemObject = item {
            self.textLabel!.text = itemObject.name ?? "?"
            let isDir = itemObject.isdir ?? false
            if isDir {
                self.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }
            let img = UIImage(named: isDir ? "folder" : "file")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            
            self.imageView!.image = img
        }
    }

}
