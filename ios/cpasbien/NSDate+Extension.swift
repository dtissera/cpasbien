//
//  NSDate+Extension.swift
//  cpasbien
//
//  Created by David Tisserand on 26/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import Foundation

extension NSDate {
    class var sharedJsDateFormatter: NSDateFormatter {
        struct Static {
            static var instance: NSDateFormatter?
        }
        
        if (Static.instance == nil) {
            Static.instance = {() -> NSDateFormatter in
                let df = NSDateFormatter()
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                df.timeZone = NSTimeZone(name: "GMT")
                return df
                }()
        }
        
        return Static.instance!
    }
    
    class var sharedWriteDateFormatter: NSDateFormatter {
        struct Static {
            static var instance: NSDateFormatter?
        }
        
        if (Static.instance == nil) {
            Static.instance = {() -> NSDateFormatter in
                let df = NSDateFormatter()
                df.dateFormat = "yyyy-MM-dd HH:mm"
                return df
                }()
        }
        
        return Static.instance!
    }

    
    public class func fromJavascriptDate(string: String) -> NSDate? {
        return NSDate.sharedJsDateFormatter.dateFromString(string)
    }
    
    public func toString() -> NSString {
        return NSDate.sharedWriteDateFormatter.stringFromDate(self)
    }

}