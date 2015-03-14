//
//  Connect.swift
//  cpasbien
//
//  Created by David Tisserand on 22/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftTask

@objc
public class Connect: NSObject, NSURLSessionDelegate {
    //public typealias CompletionHandler = (json: JSON?, error: NSErrorPointer) -> Void
    public typealias CompletionHandler = (result: FailableOf<JSON>) -> Void
    
    lazy var session: NSURLSession = {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        return NSURLSession(configuration: config, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        }()
    
    class var shared: Connect {
        struct Static {
            static var instance: Connect?
        }
        
        if (Static.instance == nil) {
            Static.instance = Connect()
        }
        
        return Static.instance!
    }
    
    // -------------------------------------------------------------------------
    // MARK: - private methods
    // -------------------------------------------------------------------------
    private func errorFromRowData(data: NSData?) -> String? {
        var res: String? = nil
        if let errorData = data {
            let json = JSON(data: errorData)
            if let jsonError = json.error {
                res = jsonError.localizedDescription
            }
            else {
                if let msg = json["message"].string {
                    res = msg
                }
                else {
                    res = json.rawString()
                }
            }
            
        }
        
        return res
    }
    
    public func buildTask(request: NSURLRequest, completionHandler: CompletionHandler?) -> NSURLSessionDataTask {
        let dataTask: NSURLSessionDataTask = self.session.dataTaskWithRequest(request, completionHandler: { (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            var errorObj: (statusCode: Int, message: String)?
            var resJson: JSON? = nil
            if error == nil {
                if let httpResponse = response as? NSHTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        if (data != nil) {
                            let json = JSON(data: data)
                            if let jsonError = json.error {
                                errorObj = (statusCode: httpResponse.statusCode, message: jsonError.localizedDescription)
                            }
                            else {
                                resJson = json
                            }
                        }
                        else {
                            errorObj = (statusCode: httpResponse.statusCode, message: "?? empty data !")
                        }
                    }
                    else {
                        if let errorStr = self.errorFromRowData(data) {
                            errorObj = (statusCode: httpResponse.statusCode, message: errorStr)
                        }
                        else {
                            errorObj = (statusCode: httpResponse.statusCode, message: NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode))
                        }
                    }
                }
            }
            else {
                errorObj = (statusCode: -1, message: error.localizedDescription)
            }
            
            var resErr: NSError? = nil
            
            
            // completion handler
            if let handler = completionHandler {
                
                //handler(json: resJson, error:&resErr)
                
                // populate NSError id needed
                if let err = errorObj {
                    let scError = Error(code: -1, domain: "cpasbien", userInfo: [NSLocalizedDescriptionKey: err.message])
                    handler(result: FailableOf<JSON>.Failure(scError))
                }
                else {
                    handler(result: FailableOf<JSON>(resJson!))
                }
            }
        })
        return dataTask
    }
    
    func promiseTask(request: NSURLRequest) -> Task<Float, JSON, Error> {
        let task = Task<Float, JSON, Error> { progress, fulfill, reject, configure in
            let dataTask = self.buildTask(request, completionHandler: { (result) -> Void in
                if (!result.failed) {
                    if let json = result.value {
                        fulfill(json)
                    }
                    else {
                        let scError = Error(code: -1, domain: "cpasbien", userInfo: [NSLocalizedDescriptionKey: "?? empty json"])
                        reject(scError)
                    }
                }
                else {
                    if let err = result.error {
                        reject(err)
                    }
                }
            })

            configure.cancel = { [weak dataTask] in
                if let t = dataTask {
                    t.cancel()
                }
            }
            
            dataTask.resume()
        }
        return task
    }
    
}