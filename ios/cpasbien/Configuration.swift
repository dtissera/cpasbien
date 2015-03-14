//
//  Configuration.swift
//  cpasbien
//
//  Created by David Tisserand on 14/03/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import Foundation

class Configuration {
    struct Consts {
        #if LOCAL
        static let serverUrl = "http://127.0.0.1:8080/api/1/"
        #else
        static let serverUrl = "http://192.168.1.20:8080/api/1/"
        #endif
    }
}