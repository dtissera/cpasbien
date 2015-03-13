//
//  SearchItem.swift
//  cpasbien
//
//  Created by David Tisserand on 26/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import Foundation
import SwiftyJSON

class SearchItem {
    var id: String?
    var research: String?
    var missingCount: Int?
    var count: Int?
    var added: NSDate?
    var updated: NSDate?
    
    init() {
    }
    
    init(json: JSON) {
        self.fillFromJson(json)
    }
    
    func fillFromJson(json: JSON) {
        self.id = json["id"].string
        self.research = json["research"].string
        self.missingCount = json["missingCount"].int
        self.count = json["count"].int
        if let added = json["added"].string {
            if let date = NSDate.fromJavascriptDate(added) {
                self.added = date
            }
        }
        if let updated = json["updated"].string {
            if let date = NSDate.fromJavascriptDate(updated) {
                self.updated = date
            }
        }

    }
}
