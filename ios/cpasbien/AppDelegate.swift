//
//  AppDelegate.swift
//  cpasbien
//
//  Created by David Tisserand on 22/02/2015.
//  Copyright (c) 2015 dtissera. All rights reserved.
//

import UIKit
import CocoaLumberjack
import DTIToastCenter
import SWRevealViewController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, SWRevealViewControllerDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        MainObject.shared.setupAppearance()
        
        let frontVc = MainObject.shared.storyBoardMain.instantiateViewControllerWithIdentifier("navHomeVcId") as UINavigationController
        let rearVc = MainObject.shared.storyBoardMain.instantiateViewControllerWithIdentifier("RearListVc") as UIViewController

        let reveal = SWRevealViewController(rearViewController: rearVc, frontViewController: frontVc)
        reveal.delegate = self
        reveal.frontViewShadowOffset = CGSize(width: 0.0, height: 1.0)
        reveal.frontViewShadowRadius = 1.0
        
        // CocoaLumberjack
        DDLog.addLogger(DDASLLogger.sharedInstance())
        DDLog.addLogger(DDTTYLogger.sharedInstance())
        DDASLLogger.sharedInstance().logFormatter = DTILogFormatter()
        DDTTYLogger.sharedInstance().logFormatter = DTILogFormatter()
        DDTTYLogger.sharedInstance().colorsEnabled = true
        DDLogConfigurationSwift.configure()
        
        // DTIToastCenter
        DTIToastCenter.defaultCenter.registerCenter()
        
        #if DEBUG
            DDLog.logVerbose("DEBUG IS SET")
        #endif
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        if let win = self.window {
            win.rootViewController = reveal
            win.makeKeyAndVisible()
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
}

