//
//  AppDelegate.swift
//  Demo_Chat
//
//  Created by Nguyen Van Hung on 2/1/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import NCMB
import Firebase
import UserNotifications
import FBSDKCoreKit
import Fabric
import Crashlytics
import TwitterKit
import GoogleMaps
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var currUser: UserModel?
    let manager = NetworkReachabilityManager(host: HOST_TEST_NETWORK)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        NCMB.setApplicationKey(MBAAS_APP_KEY, clientKey: MBAAS_CLIENT_KEY)
        self.requestNotification(application: application)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        Fabric.with([Crashlytics.self, Twitter.self])
        AnalyticsHelper.shared.shareManage()
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let navigationController: UINavigationController = UINavigationController(rootViewController: UIManager.shared.vcToSetFirst())
        navigationController.isNavigationBarHidden = true
        
        self.window?.rootViewController = navigationController
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        
        GoogleAdMobHelper.shared.initializeBannerView(isLiveUnitID: true)
        GoogleAdMobHelper.shared.initializeInterstitial(isLiveUnitID: true)
        
        MainDB.shared.loadGenreList()
        if let _ = Helper.shared.getUserDefault(key: kAllowLocation) {} else {
            Helper.shared.saveUserDefault(key: kAllowLocation, value: true)
        }
        
        if let _ = Helper.shared.getUserDefault(key: kCopyMusicToDocument) {} else {
            DownloadHelper.shared.addFileMusicAndSaveLocalDB(musics: MainDB.shared.getSongModelDefault(), completionHandler: { (success) in
                if success {
                    Helper.shared.saveUserDefault(key: kCopyMusicToDocument, value: true)
                }
            })
        }
        
        //Check network
        manager?.listener = { status in
            switch status {
            case .notReachable:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNotReachable), object: nil, userInfo: nil)
                break
            case .reachable(_):
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationReachable), object: nil, userInfo: nil)
                break
            default:
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNotReachable), object: nil, userInfo: nil)
                break
            }
        }
        manager?.startListening()
        
        return true
    }
    
    override init() {
        let filePath = Bundle.main.path(forResource: GOOGLE_SERVER_FILE_NAME, ofType: "plist")!
        if let options = FIROptions(contentsOfFile: filePath) {
            FIRApp.configure(with: options)
        }
        GMSServices.provideAPIKey(MAP_KEY)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        #if DEBUG
            print("applicationDidEnterBackground")
        #endif
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        #if DEBUG
            print("applicationWillEnterForeground")
        #endif
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        FBSDKAppEvents.activateApp()
        application.applicationIconBadgeNumber = 0
        application.cancelAllLocalNotifications()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: kNotificationShowMessage), object: nil)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let myStr = url.absoluteString
        if (myStr.range(of: URL_SCHEME_FACEBOOK) != nil) {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        } else if (myStr.range(of: URL_SCHEME_TWITTER) != nil) {
            return Twitter.sharedInstance().application(application, open: url, options: annotation as! [AnyHashable : Any])
        }
        
        return false
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
       
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        #if DEBUG
            print(userInfo)
        #endif
        
        if let push_type = userInfo["push_type"] {
            if push_type as! String == TYPE_PUSH_CHAT {
                if let aps: [String:AnyObject] = userInfo["aps"] as! [String : AnyObject]? {
                    if let alert: [String:AnyObject] = aps["alert"] as! [String : AnyObject]? {
                        if let title = alert["title"], let subTitle = alert["body"] {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationShowMessage), object: nil, userInfo: ["title": title as! String, "subTitle": subTitle as! String])
                        }
                    }
                }
            } else if push_type as! String == "PushAdvertisement" {
                
            }
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        #if DEBUG
            print("Unable to register for remote notifications: \(error.localizedDescription)")
        #endif
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        #if DEBUG
            print("Device Token: \(token)")
        #endif
        
        let currInstallation: NCMBInstallation = NCMBInstallation.current()
        currInstallation.setDeviceTokenFrom(deviceToken)
        self.handleInstallation(currInstallation: currInstallation)
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        #if DEBUG
            print(userInfo)
        #endif
        
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        #if DEBUG
            print(userInfo)
        #endif
        
        completionHandler()
    }
}

extension AppDelegate {
    func requestNotification(application: UIApplication) {
        if #available(iOS 10.0, *){
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .badge, .sound]) {granted, error in
                if error != nil {
                    return
                }
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(setting)
            application.registerForRemoteNotifications()
        }
    }
    
    func handleInstallation(currInstallation: NCMBInstallation) {
        self.checkInstallation(currInstallation: currInstallation) { (installation) in
            if installation == nil {
                self.saveInstallation(installation: currInstallation, completionHandler: { (isOK) in
                    if isOK {
                        #if DEBUG
                            print("Register push successfull")
                        #endif
                    }
                })
            } else {
                currInstallation.objectId = installation?.objectId
                self.saveInstallation(installation: installation!, completionHandler: { (isOK) in
                    if isOK {
                        #if DEBUG
                            print("Update push successfull")
                        #endif
                    }
                })
            }
        }
    }
    
    func checkInstallation(currInstallation: NCMBInstallation, completionHandler: @escaping(NCMBInstallation?) -> Void) {
        let query = NCMBInstallation.query()
        query?.whereKey("deviceToken", equalTo: currInstallation.deviceToken)
        query?.getFirstObjectInBackground({ (object, error) in
            if (error == nil && object != nil) {
                completionHandler(object as? NCMBInstallation)
            } else {
                completionHandler(nil)
            }
        })
    }
    
    func saveInstallation(installation: NCMBInstallation, completionHandler: @escaping(Bool) -> Void) {
        installation.setObject(UIDevice.current.modelName, forKey: "device")
        installation.setObject(UIDevice.current.systemVersion, forKey: "OS")
        if (installation.object(forKey: "allow_push") == nil) {
            installation.setObject(true, forKey: "allow_push")
        }
        
        if let userInfo = Helper.shared.getUserDefault(key: kUserInfo) as? [String:String] {
            installation.setObject(userInfo, forKey: "user_info")
            if let uid = userInfo["user_id"] {
                installation.setObject(uid, forKey: "user_id")
            } else {
                installation.setObject("", forKey: "user_id")
            }
        } else {
            installation.setObject("", forKey: "user_id")
        }
        
        installation.saveInBackground { (error) in
            let isOK = error == nil ? true : false
            completionHandler(isOK)
        }
    }
}
