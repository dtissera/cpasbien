//
//  SynoPathItem.swift
//  cpasbien
//
//  Created by David Tisserand on 15/03/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import Foundation
import SwiftyJSON

class SynoPathItem {
    class FileItem {
        var name: String?
        var isdir: Bool?
        var path: String?
        
        init() {
            
        }
        
        init(json: JSON) {
            self.fillFromJson(json)
        }
        
        func fillFromJson(json: JSON) {
            self.name = json["name"].string
            self.isdir = json["isdir"].bool
            self.path = json["path"].string
        }

    }
    
    var files = Array<FileItem>()
    
    init() {
    }
    
    init(json: JSON, isRoot: Bool) {
        self.fillFromJson(json)
        
        if !isRoot {
            let parentItem = FileItem()
            parentItem.name = ".."
            parentItem.isdir = true
            parentItem.path = ".."

            self.files.insert(parentItem, atIndex: 0)
        }
    }
    
    func fillFromJson(json: JSON) {
        self.files.removeAll(keepCapacity: false)

        for (index: String, subJson: JSON) in json["data"]["files"] {
            self.files.append(FileItem(json: subJson))
        }
    }
}