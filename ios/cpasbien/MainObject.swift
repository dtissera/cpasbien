//
//  MainObject.swift
//  cpasbien
//
//  Created by David Tisserand on 28/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import Foundation
import UIKit

class MainObject {
    struct Consts {
        static let BAR_TINT_COLOR = "#a09b96"
        static let BAR_TEXT_COLOR = "#ffffff"
        
        static let REARVC_BG_COLOR = "#666666"
        
        static let DARK_TEXT = "#787878"
    }
    
    class var shared: MainObject {
        struct Static {
            static var instance: MainObject?
        }
        
        if (Static.instance == nil) {
            Static.instance = MainObject()
        }
        
        return Static.instance!
    }

    let storyBoardMain = UIStoryboard(name: "Main", bundle: nil)
    
    init() {
        #if DEBUG
            /*
            for family in UIFont.familyNames() {
                if let familyName = family as? String {
                    println(familyName)
                    if let fonts = UIFont.fontNamesForFamilyName(familyName) as? Array<String> {
                        for fontName in fonts {
                            println("  \(fontName)")
                        }
                    }
                }
            }*/
        #endif
    }
    
    func setupAppearance() {
        UINavigationBar.appearance().tintColor = UIColor(rgba: Consts.BAR_TEXT_COLOR)
        UINavigationBar.appearance().barTintColor = UIColor(rgba: Consts.BAR_TINT_COLOR)
        UINavigationBar.appearance().barStyle = UIBarStyle.Black
    }
}