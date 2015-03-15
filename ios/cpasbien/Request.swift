//
//  Request.swift
//  cpasbien
//
//  Created by David Tisserand on 22/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import UIKit
import SwiftyJSON
import CocoaLumberjack

class Request {
    class RestUrlFactory {
        struct Consts {
            static let REST_PING = "ping"
            static let REST_RESEARCH = "research"
            static let REST_RESEARCH_ALL = "all"
            static let REST_RESEARCH_UPDATE = "update"
            static let REST_RESEARCH_CREATE = "create"
            static let REST_RESEARCH_ENABLE = "enable"
            static let REST_RESEARCH_DISABLE = "disable"
            static let REST_RESEARCH_DOWNLOAD = "download"
            static let REST_SYNO = "syno"
            static let REST_SYNO_CHECK = "check"
            static let REST_SYNO_DOWNLOAD = "download"
            static let REST_SYNO_LIST = "list"
            static let REST_SYNO_RENAME = "rename"
        }
        
        private var url: NSURL?
        
        init() {
            self.url = NSURL(string: Configuration.Consts.serverUrl)
            
            DDLog.logInfo("root=\(Configuration.Consts.serverUrl)")
        }
        
        func research() -> RestUrlFactory {
            if let url = self.url {
                self.url = url.URLByAppendingPathComponent(Consts.REST_RESEARCH)
            }
            return self
        }
        
        func all() -> RestUrlFactory {
            if let url = self.url {
                self.url = url.URLByAppendingPathComponent(Consts.REST_RESEARCH_ALL)
            }
            return self
        }
        
        func update() -> RestUrlFactory {
            if let url = self.url {
                self.url = url.URLByAppendingPathComponent(Consts.REST_RESEARCH_UPDATE)
            }
            return self
        }
        
        func create() -> RestUrlFactory {
            if let url = self.url {
                self.url = url.URLByAppendingPathComponent(Consts.REST_RESEARCH_CREATE)
            }
            return self
        }

        func enable() -> RestUrlFactory {
            if let url = self.url {
                self.url = url.URLByAppendingPathComponent(Consts.REST_RESEARCH_ENABLE)
            }
            return self
        }
        
        func disable() -> RestUrlFactory {
            if let url = self.url {
                self.url = url.URLByAppendingPathComponent(Consts.REST_RESEARCH_DISABLE)
            }
            return self
        }
        
        func identifier(ident: String)-> RestUrlFactory {
            if let url = self.url {
                self.url = url.URLByAppendingPathComponent(ident)
            }
            return self
        }

        func ping() -> RestUrlFactory {
            if let url = self.url {
                self.url = url.URLByAppendingPathComponent(Consts.REST_PING)
            }
            return self
        }

        func syno() -> RestUrlFactory {
            if let url = self.url {
                self.url = url.URLByAppendingPathComponent(Consts.REST_SYNO)
            }
            return self
        }
        
        func check() -> RestUrlFactory {
            if let url = self.url {
                self.url = url.URLByAppendingPathComponent(Consts.REST_SYNO_CHECK)
            }
            return self
        }

        func download() -> RestUrlFactory {
            if let url = self.url {
                self.url = url.URLByAppendingPathComponent(Consts.REST_SYNO_DOWNLOAD)
            }
            return self
        }
        
        func list() -> RestUrlFactory {
            if let url = self.url {
                self.url = url.URLByAppendingPathComponent(Consts.REST_SYNO_LIST)
            }
            return self
        }

        func rename() -> RestUrlFactory {
            if let url = self.url {
                self.url = url.URLByAppendingPathComponent(Consts.REST_SYNO_RENAME)
            }
            return self
        }

        func downloadMissing() -> RestUrlFactory {
            if let url = self.url {
                self.url = url.URLByAppendingPathComponent(Consts.REST_RESEARCH_DOWNLOAD)
            }
            return self
        }
        
        func toUrl() -> NSURL {
            return (self.url == nil ? NSURL() : self.url!)
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Web services
    // -------------------------------------------------------------------------
    class func ping() -> NSMutableURLRequest {
        DDLog.logInfo("...")
        var restUrlFactory = RestUrlFactory()
        
        var req = NSMutableURLRequest(URL: restUrlFactory.ping().toUrl())
        req.HTTPMethod = "GET"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        return req
    }
    
    class func researchAll() -> NSMutableURLRequest {
        DDLog.logInfo("...")
        var restUrlFactory = RestUrlFactory()
        
        var req = NSMutableURLRequest(URL: restUrlFactory.research().all().toUrl())
        req.HTTPMethod = "GET"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        return req
    }
    
    class func research(ident: String) -> NSMutableURLRequest {
        DDLog.logInfo("ident=\(ident)")
        var restUrlFactory = RestUrlFactory()
        
        var req = NSMutableURLRequest(URL: restUrlFactory.research().identifier(ident).toUrl())
        req.HTTPMethod = "GET"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        return req
    }

    class func researchUpdate(ident: String) -> NSMutableURLRequest {
        DDLog.logInfo("ident=\(ident)")
        var restUrlFactory = RestUrlFactory()
        
        var req = NSMutableURLRequest(URL: restUrlFactory.research().update().toUrl())
        req.HTTPMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        var components = NSURLComponents()
        let idQueryItem = NSURLQueryItem(name: "id", value: ident)
        components.queryItems = [idQueryItem]
        if let query = components.percentEncodedQuery  {
            req.HTTPBody = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        }

        return req
    }

    class func researchEnable(ident: String, order: Int?) -> NSMutableURLRequest {
        DDLog.logInfo("ident=\(ident)")
        var restUrlFactory = RestUrlFactory()
        
        var req = NSMutableURLRequest(URL: restUrlFactory.research().enable().toUrl())
        req.HTTPMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var components = NSURLComponents()
        components.queryItems = [NSURLQueryItem(name: "id", value: ident)]
        if let o = order {
            components.queryItems!.append(NSURLQueryItem(name: "order", value: String(o)))
        }

        if let query = components.percentEncodedQuery  {
            req.HTTPBody = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        }
        
        return req
    }

    class func researchDisable(ident: String, order: Int?) -> NSMutableURLRequest {
        DDLog.logInfo("ident=\(ident)")
        var restUrlFactory = RestUrlFactory()
        
        var req = NSMutableURLRequest(URL: restUrlFactory.research().disable().toUrl())
        req.HTTPMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var components = NSURLComponents()
        components.queryItems = [NSURLQueryItem(name: "id", value: ident)]
        if let o = order {
            components.queryItems!.append(NSURLQueryItem(name: "order", value: String(o)))
        }

        if let query = components.percentEncodedQuery  {
            req.HTTPBody = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        }
        
        return req
    }

    class func researchCreate(title: String) -> NSMutableURLRequest {
        DDLog.logInfo("title=\(title)")
        var restUrlFactory = RestUrlFactory()
        
        var req = NSMutableURLRequest(URL: restUrlFactory.research().create().toUrl())
        req.HTTPMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        var components = NSURLComponents()
        let titleQueryItem = NSURLQueryItem(name: "title", value: title)
        components.queryItems = [titleQueryItem]
        if let query = components.percentEncodedQuery  {
            req.HTTPBody = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        }
        
        return req
    }

    class func researchDelete(ident: String) -> NSMutableURLRequest {
        DDLog.logInfo("ident=\(ident)")
        var restUrlFactory = RestUrlFactory()
        
        var req = NSMutableURLRequest(URL: restUrlFactory.research().identifier(ident).toUrl())
        req.HTTPMethod = "DELETE"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        return req
    }

    class func researchDownload(ident: String) -> NSMutableURLRequest {
        DDLog.logInfo("ident=\(ident)")
        var restUrlFactory = RestUrlFactory()
        
        var req = NSMutableURLRequest(URL: restUrlFactory.research().downloadMissing().toUrl())
        req.HTTPMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var components = NSURLComponents()
        components.queryItems = [NSURLQueryItem(name: "id", value: ident)]
        
        if let query = components.percentEncodedQuery  {
            req.HTTPBody = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        }
        
        return req
    }

    class func synoCheck() -> NSMutableURLRequest {
        DDLog.logInfo("...")
        var restUrlFactory = RestUrlFactory()
        
        var req = NSMutableURLRequest(URL: restUrlFactory.syno().check().toUrl())
        req.HTTPMethod = "GET"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        return req
    }
    
    class func synoList(path: String) -> NSMutableURLRequest {
        DDLog.logInfo("path=\(path)")
        var restUrlFactory = RestUrlFactory()
        
        var req = NSMutableURLRequest(URL: restUrlFactory.syno().list().toUrl())
        req.HTTPMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var components = NSURLComponents()
        components.queryItems = [NSURLQueryItem(name: "path", value: path)]
        if let query = components.percentEncodedQuery  {
            req.HTTPBody = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        }
        
        return req
    }

    class func synoRename(path: String, name: String) -> NSMutableURLRequest {
        DDLog.logInfo("path=\(path)")
        var restUrlFactory = RestUrlFactory()
        
        var req = NSMutableURLRequest(URL: restUrlFactory.syno().rename().toUrl())
        req.HTTPMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        var components = NSURLComponents()
        components.queryItems = [
            NSURLQueryItem(name: "path", value: path),
            NSURLQueryItem(name: "name", value: name)
        ]
        if let query = components.percentEncodedQuery  {
            req.HTTPBody = query.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        }
        
        return req
    }

}