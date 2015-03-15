//
//  Tools.swift
//  cpasbien
//
//  Created by David Tisserand on 01/03/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import Foundation

class Tools {
    class func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    class func sync(lock: AnyObject, closure: () -> Void) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
}
