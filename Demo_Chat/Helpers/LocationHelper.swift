//
//  LocationHelper.swift
//  Demo_Chat
//
//  Created by HungNV on 8/2/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

protocol LocationHelperDelegate: class {
    func didFinishedEnableLocation()
    func didFinishedUpdateLocation(lat: Double, lng: Double)
}

class LocationHelper: NSObject, CLLocationManagerDelegate {
    static let shared = LocationHelper()
    
    var locationManager: CLLocationManager!
    var accessDenied: Bool!
    var lat: Double = 0
    var lng: Double = 0
    weak var delegate: LocationHelperDelegate?
    var timer: Timer!
    
    func shareManage() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.distanceFilter = kCLDistanceFilterNone
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.denied {
            self.accessDenied = true
        } else if status == CLAuthorizationStatus.notDetermined {
            self.accessDenied = true
            self.locationManager.requestWhenInUseAuthorization()
        } else {
            self.allowLocation()
        }
    }
    
    func allowLocation() {
        self.accessDenied = false
        self.locationManager.startUpdatingLocation()
        
        if let location:CLLocationCoordinate2D = (self.locationManager.location?.coordinate) {
            self.lat = location.latitude
            self.lng = location.longitude
        }
        
        self.delegate?.didFinishedEnableLocation()
        self.createTimer()
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "location", action: "authen_request", label: "start", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "location", action: "authen_request", label: "start")
    }
    
    func deniedLocation() {
        self.accessDenied = true
        self.locationManager.stopUpdatingLocation()
        
        self.delegate?.didFinishedEnableLocation()
        self.removeTimer()
        AnalyticsHelper.shared.sendGoogleAnalytic(category: "location", action: "authen_request", label: "deny", value: nil)
        AnalyticsHelper.shared.sendFirebaseAnalytic(event: kFIREventSelectContent, category: "location", action: "authen_request", label: "deny")
    }
    
    //MARK:- Timer
    func createTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 600, target: self.locationManager, selector: #selector(self.locationManager.startUpdatingLocation), userInfo: nil, repeats: true)
    }
    
    func removeTimer() {
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil
        }
    }
    
    //MARK:- CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.notDetermined:
            break
        case CLAuthorizationStatus.denied:
            self.deniedLocation()
            break
        case CLAuthorizationStatus.authorizedWhenInUse:
            self.allowLocation()
            break
        case CLAuthorizationStatus.authorizedAlways:
            self.allowLocation()
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        #if DEBUG
            print("location error is = \(error.localizedDescription)")
        #endif
        self.accessDenied = true
        self.removeTimer()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.accessDenied == true {
            self.accessDenied = false
            self.createTimer()
        }
        
        let location:CLLocationCoordinate2D = (manager.location?.coordinate)!
        self.lat = location.latitude
        self.lng = location.longitude
        self.locationManager.stopUpdatingLocation()
        
        self.delegate?.didFinishedUpdateLocation(lat: self.lat, lng: self.lng)
        
        #if DEBUG
            print("Current Locations = \(location.latitude) \(location.longitude)")
        #endif
    }
}
