//
//  MapViewController.swift
//  Demo_Chat
//
//  Created by HungNV on 8/2/17.
//  Copyright © 2017 HungNV. All rights reserved.
//

import UIKit
import GoogleMaps
import SocketIO

class MapViewController: BaseViewController {
    @IBOutlet weak var mapView: GMSMapView!
    let socket = SocketIOClient(socketURL: URL(string: SERVER_URL)!, config: [.log(true), .forcePolling(true)])
    var markerDict:[String:GMSMarker] = [:]
    let locationHelper = LocationHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        
        self.initMap()
        self.startSocketIO()
        
        NotificationCenter.default.addObserver(self, selector: #selector(privateLocation), name: NSNotification.Name(rawValue: kNotificationPrivateLocation), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsHelper.shared.setGoogleAnalytic(name: kGAIScreenName, value: "map_screen")
        AnalyticsHelper.shared.setFirebaseAnalytic(screenName: "map_screen", screenClass: classForCoder.description())
    }
    
    func setupView() {
        self.setupNavigation()
    }
    
    func setupNavigation() {
        setupNavigationBar(vc: self, title: Define.shared.getNameMapScreen().uppercased(), leftText: nil, leftImg: #imageLiteral(resourceName: "arrow_back"), leftSelector: #selector(self.actBack(btn:)), rightText: nil, rightImg: nil, rightSelector: nil, isDarkBackground: true, isTransparent: true)
    }
    
    func actBack(btn: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func initMap() {
        self.locationHelper.shareManage()
        self.locationHelper.delegate = self
        if self.locationHelper.lat == 0.0 || self.locationHelper.lng == 0.0 {
            self.locationHelper.lat = 10.7910203
            self.locationHelper.lng = 106.6926057
        }
        
        let camera: GMSCameraPosition = GMSCameraPosition.camera(withLatitude: self.locationHelper.lat, longitude: self.locationHelper.lng, zoom: 13.5)
        self.mapView.camera = camera
    }
    
    func startSocketIO() {
        socket.on(clientEvent: .connect) { (data, ack) in
            #if DEBUG
                print("Client connected")
            #endif
            
            guard let id = self.appDelegate.currUser?.id else { return }
            guard let displayName = self.appDelegate.currUser?.display_name else { return }
            if let isAllowLocation: Bool = Helper.shared.getUserDefault(key: kAllowLocation) as! Bool? {
                if isAllowLocation {
                    self.socket.emit("location", ["\(id)_\(displayName)", self.locationHelper.lat, self.locationHelper.lng])
                } else {
                    self.socket.emit("location", ["\(id)_\(displayName)", 0, 0])
                }
            }
        }
        
        socket.on("locationUpdated") { [weak self] (data, ack) in
            guard let `self` = self else { return }
            guard let coords = data.first as? [String:Any] else { return }
            
            for (k, v) in coords {
                guard let coord = v as? [String: Double] else { continue }
                let lat = coord["lat"] ?? 0
                let lng = coord["lng"] ?? 0
                
                let coordForMarker = CLLocationCoordinate2D(latitude: lat, longitude: lng)
                
                if let marker = self.markerDict[k] {
                    marker.position = coordForMarker
                } else {
                    let marker = self.createMarker(title: k.components(separatedBy: "_").last ?? "NoName", coord: coordForMarker)
                    marker.map = self.mapView
                    
                    self.markerDict[k] = marker
                }
            }
        }
        
        socket.connect()
    }
    
    func createMarker(title: String, coord: CLLocationCoordinate2D) -> GMSMarker {
        let gmsMarker = GMSMarker(position: coord)
        gmsMarker.icon = #imageLiteral(resourceName: "truck")
        gmsMarker.appearAnimation = .pop
        gmsMarker.title = title
        gmsMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        
        return gmsMarker
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MapViewController: LocationHelperDelegate {
    func didFinishedEnableLocation() {
        self.mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2DMake(self.locationHelper.lat, self.locationHelper.lng), zoom: 13.5, bearing: 0, viewingAngle: 0)
        
        guard let id = self.appDelegate.currUser?.id else { return }
        guard let displayName = self.appDelegate.currUser?.display_name else { return }
        if let isAllowLocation: Bool = Helper.shared.getUserDefault(key: kAllowLocation) as! Bool? {
            if isAllowLocation {
                self.socket.emit("location", ["\(id)_\(displayName)", self.locationHelper.lat, self.locationHelper.lng])
            } else {
                self.socket.emit("location", ["\(id)_\(displayName)", 0, 0])
            }
        }
    }
    
    func didFinishedUpdateLocation(lat: Double, lng: Double) {
        guard let id = self.appDelegate.currUser?.id else { return }
        guard let displayName = self.appDelegate.currUser?.display_name else { return }
        if let isAllowLocation: Bool = Helper.shared.getUserDefault(key: kAllowLocation) as! Bool? {
            if isAllowLocation {
                self.socket.emit("location", ["\(id)_\(displayName)", lat, lng])
            } else {
                self.socket.emit("location", ["\(id)_\(displayName)", 0, 0])
            }
        }
    }
    
    func privateLocation() {
        guard let id = self.appDelegate.currUser?.id else { return }
        guard let displayName = self.appDelegate.currUser?.display_name else { return }
        self.socket.emit("location", ["\(id)_\(displayName)", 0, 0])
    }
}
