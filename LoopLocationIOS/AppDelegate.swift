//
//  AppDelegate.swift
//  Loop Location Sample
//
//  Created by Xuwen Cao on 5/23/16.
//  Copyright © 2016 Microsoft. All rights reserved.
//

import UIKit
import LoopSDK
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LoopSDKListener, LocationManagerListener {

	var window: UIWindow?
	
	var loopInitialized = false;
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		var appID = ""
		var appToken = ""
		
		if let path = NSBundle.mainBundle().pathForResource("Info", ofType: "plist"),
			let dict = NSDictionary(contentsOfFile: path) {
			
			if let userId = dict["LOOP_USER_ID_PROP"] as? String where userId != "",
				let deviceId = dict["LOOP_DEVICE_ID_PROP"] as? String where deviceId != "" {
				LoopSDK.setUserID(userId)
				LoopSDK.setDeviceID(deviceId)
			}
			
			if let appID_plist = dict["LOOP_APP_ID_PROP"] as? String where appID_plist != "",
				let appToken_plist = dict["LOOP_APP_TOKEN_PROP"] as? String where appToken_plist != "" {
				appID = appID_plist;
				appToken = appToken_plist;
			}
		}
		
		let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Sound], categories: nil)
		UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
		
		LoopSDK.initialize(self, appID: appID, token: appToken);
		LoopSDK.locationManager.addListener(self);

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


	func onLoopInitialized() {
		print("on initialized")

		loopInitialized = true;
	}
	
	func onLoopInitializeError(error: String) {
		print("initialize error \(error)")
		
		loopInitialized = false;
	}
	
	func pushNotification(message: String) {
		let notification = UILocalNotification()
		notification.fireDate = NSDate(timeIntervalSinceNow: 0);
		notification.alertBody = message
		UIApplication.sharedApplication().scheduleLocalNotification(notification)
	}
	
	@objc func onLocationExit(newVisit: CLVisit, location: LoopLocation) {
		LoopSDK.logManager.logEvent("location exit reported")

		location.labels.sortInPlace { $0.score > $1.score}
		
		if let label = location.labels.first {
			if (label.name == "home") {
				pushNotification("Left Home at \(newVisit.departureDate.toLocalStringWithFormat())")
			} else if (label.name == "work") {
				pushNotification("Left Work at \(newVisit.departureDate.toLocalStringWithFormat())")
			} else {
				pushNotification("Left Unknown at \(newVisit.departureDate.toLocalStringWithFormat())")
			}
		}
	}
	
	@objc func onLocationEnter(newVisit: CLVisit, location: LoopLocation) {
		LoopSDK.logManager.logEvent("location enter reported")
		
		location.labels.sortInPlace { $0.score > $1.score}

		if let label = location.labels.first {
			if (label.name == "home") {
				pushNotification("Entered Home at \(newVisit.arrivalDate.toLocalStringWithFormat())")
			} else if (label.name == "work") {
				pushNotification("Entered Work at \(newVisit.arrivalDate.toLocalStringWithFormat())")
			}	else {
				pushNotification("Entered Unknown at \(newVisit.arrivalDate.toLocalStringWithFormat())")
			}
		}
	}
}

