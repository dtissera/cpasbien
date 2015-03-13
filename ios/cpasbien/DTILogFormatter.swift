//
//  DTILogFormatter.swift
//  cpasbien
//
//  Created by David Tisserand on 27/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import Foundation
import CocoaLumberjack

class DTILogFormatter: NSObject, DDLogFormatter {
    let threadUnsafeDateFormatter: NSDateFormatter = {() -> NSDateFormatter in
        let res = NSDateFormatter()
        res.formatterBehavior = NSDateFormatterBehavior.Behavior10_4
        res.dateFormat = "HH:mm:ss:SSS"
        return res
    }()
    
    var loggerCount: Int = 0
    
    override init() {
        super.init()
    }
    
    func formatLogMessage(logMessage: DDLogMessage!) -> String! {
        var logLevel: String = ""
        switch logMessage.level {
            case .Debug: logLevel = "D"
            case .Error: logLevel = "E"
            case .Info: logLevel = "I"
            case .Verbose: logLevel = "V"
            case .Warning: logLevel = "W"
            default:
                logLevel = "V"
        }
        let dt = self.threadUnsafeDateFormatter.stringFromDate(logMessage.timestamp)
        let fname = "\(logMessage.file.lastPathComponent):\(logMessage.line)"

        var thname = ""
        if logMessage.queueLabel != "com.apple.main-thread" {
            thname += logMessage.queueLabel
        }
        if !logMessage.threadName.isEmpty {
            thname += "~\(logMessage.threadName)"
        }
        if thname.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0 {
            thname += ":\(logMessage.threadID)|"
        }
        
        return "\(logLevel)|\(dt)|\(thname)\(fname)|\(logMessage.function)|\(logMessage.message)"
    }
    
    func didAddToLogger(logger: DDLogger!) {
        loggerCount++
        assert(loggerCount <= 1, "This logger isn't thread-safe");
    }
    
    func willRemoveFromLogger(logger: DDLogger!) {
        loggerCount--;
    }
}