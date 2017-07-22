//
//  AppDelegate.swift
//  Math Tetris
//
//  Created by Saken Sydykov on 30.06.17.
//  Copyright © 2017 Strixit. All rights reserved.
//

import GoogleMobileAds
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        print("Game is opened")
        
        Chartboost.start(withAppId: "596cff2643150f536890853e", appSignature: "2ae441f517ad8b9d1dcf60ca16ee06dc27e373b2", delegate: nil)
        
        counter = UserDefaults.standard.integer(forKey: "counter")
        if counter == 0 {
            counter = 10 * 60
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        print("Did enter 2")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:
        
        print("Game is closed")
        
        UserDefaults.standard.set(counter, forKey: "counter")
        UserDefaults.standard.synchronize()
        
    }
}

