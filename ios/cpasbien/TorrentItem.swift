//
//  TorrentItem.swift
//  cpasbien
//
//  Created by David Tisserand on 26/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import Foundation
import SwiftyJSON

class TorrentItem {
    var order: Int?
    var name: String?
    var enabled: Bool?
    var fileSize: String?
    var date: NSDate?
    var url: String?

    init() {
        
    }
    
    init(json: JSON) {
        self.fillFromJson(json)
    }

    func fillFromJson(json: JSON) {
        self.order = json["order"].int
        self.name = json["name"].string
        self.fileSize = json["fileSize"].string
        self.url = json["url"].string
        self.enabled = json["enabled"].bool
        if let dateStr = json["date"].string {
            if let date = NSDate.fromJavascriptDate(dateStr) {
                self.date = date
            }
        }

    }
}