//
//  ViewController.swift
//  LocationTracker
//
//  Created by Ashish Mittal  on 08/04/17.
//  Copyright © 2017 Ashish Mittal . All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation

/*
 it will track the position between two points This app will contain two button swipe right and swipe left. track location will start after swipe button and it will end after left swipe it will calculate the time taken between the two locations. technology-iOS #mapkit , # uipangestures ,# framing cordinates ,# autolayout ,# dates
 */
class ViewController: UIViewController , CLLocationManagerDelegate,MKMapViewDelegate ,UIGestureRecognizerDelegate {

     var locationManager: CLLocationManager!
    
    @IBOutlet weak var bigSliderView: UIView!
    
    
    @IBOutlet weak var innerSliderView: UIView!
    
    
    @IBOutlet weak var rightInnerSliderView: UIView!
    
    @IBOutlet weak var swipeLabel: UILabel!
    
    @IBOutlet weak var upperView: UIView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    
    
     var oldLocation:CLLocation?
     var startingAppForFirstTime:Bool?
    var isEndingOfShift:Bool?
     var newLocation:CLLocation?
     var panStartPoint = CGPoint.zero
     var old:CGFloat?
     var flag:Bool?
    var startDate:Date?
    var endDate : Date?
    
    @IBOutlet weak var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLocationManager()
        startingAppForFirstTime = true
        isEndingOfShift = false
        AddingPanGestures()
        settingViewsLayout()
        settingMap()
        settingView()
       
    }
    
    func setUpLocationManager()
    {
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
            // present an alert indicating location authorization required
            // and offer to take the user to Settings for the app via
            // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }

    }
    
    func AddingPanGestures()
    {
        let panGestureRecognizerForLeftView =  UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture))
        let panGestureRecognizerForRightView =  UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGestureForRightView))
        
        self.innerSliderView.addGestureRecognizer(panGestureRecognizerForLeftView)
        self.rightInnerSliderView.addGestureRecognizer(panGestureRecognizerForRightView)
        panGestureRecognizerForLeftView.delegate = self
        panGestureRecognizerForRightView.delegate = self
    }
    
    func settingViewsLayout()
    {
        self.bigSliderView.backgroundColor = UIColor.init(hexString: colorExtension.START_COLOR)
        self.bigSliderView.layer.cornerRadius = self.bigSliderView.frame.size.height/2
        
        self.innerSliderView.layer.cornerRadius = self.innerSliderView.frame.size.height/2
        self.rightInnerSliderView.layer.cornerRadius = self.rightInnerSliderView.frame.size.height/2
    }
    
    func settingMap()
    {
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.mapType = MKMapType(rawValue: 0)!
        mapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
    }
    
    func settingView()
    {
        self.rightInnerSliderView.isHidden = true
        upperView.isHidden = true
        self.title = String_Globals.TITLE
    }
    
    func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        
      var translation = recognizer.location(in: self.bigSliderView)
        if recognizer.state == .began {
            panStartPoint = recognizer.location(in: self.bigSliderView)
            old = 0.0
            flag = false
            swipeLabel.isHidden = true
            
        }
        if recognizer.state == .changed {
            let currentPoint: CGPoint = recognizer.location(in: self.bigSliderView)
            let present = currentPoint.x - panStartPoint.x
            translation.x = present - old!
            old = present
            
            if((recognizer.view?.center.x)! + translation.x + self.innerSliderView.frame.size.width/2 >= self.bigSliderView.frame.size.width-8)
            {
                recognizer.view?.center = CGPoint(x: CGFloat(self.bigSliderView.frame.size.width-8-self.innerSliderView.frame.size.width/2), y: CGFloat((recognizer.view?.center.y)!))
                flag = false
                
            }
            else if((recognizer.view?.center.x)! + translation.x - self.innerSliderView.frame.size.width/2 <= 8)
            {
                recognizer.view?.center = CGPoint(x: CGFloat(8+self.innerSliderView.frame.size.width/2), y: CGFloat((recognizer.view?.center.y)!))
                flag = true
            }
            else
            {
                 recognizer.view?.center = CGPoint(x: CGFloat((recognizer.view?.center.x)! + translation.x), y: CGFloat((recognizer.view?.center.y)!))
                 flag = true
           }
           
        }
        if recognizer.state == .ended {
            
            if(flag == true)
            {
                recognizer.view?.center = CGPoint(x: CGFloat(8+self.innerSliderView.frame.size.width/2), y: CGFloat((recognizer.view?.center.y)!))
            }
            else
            {
                recognizer.view?.center = CGPoint(x: CGFloat(self.bigSliderView.frame.size.width-8-self.innerSliderView.frame.size.width/2), y: CGFloat((recognizer.view?.center.y)!))
                
                self.innerSliderView.isHidden = true
                self.rightInnerSliderView.isHidden = false
                startingAppForFirstTime = true
                isEndingOfShift = false
                
                mapView.removeOverlays(mapView.overlays)
                mapView.removeAnnotations(mapView.annotations)
                
                locationManager.startUpdatingLocation()
                locationManager.startUpdatingHeading()
                self.bigSliderView.backgroundColor = UIColor.init(hexString: colorExtension.END_COLOR)
                startDate = Date()
                swipeLabel.text = String_Globals.END_SHIFT_TEXT
                upperView.isHidden = true
               
               }
            swipeLabel.isHidden = false
            
            
           }
    }
    
    func addAnnotationsToMap(_ newLocation:CLLocation , _ title:String)
    {
        let point = MKPointAnnotation()
        point.coordinate = (newLocation.coordinate)
        point.title = title
        point.subtitle = String_Globals.SUBTITLE
        mapView.addAnnotation(point)
    }
    
    func handlePanGestureForRightView(_ recognizer: UIPanGestureRecognizer) {
        
        var translation = recognizer.location(in: self.bigSliderView)
        if recognizer.state == .began {
            panStartPoint = recognizer.location(in: self.bigSliderView)
            old = 0.0
            flag = false
            swipeLabel.isHidden = true
            
        }
        if recognizer.state == .changed {
            let currentPoint: CGPoint = recognizer.location(in: self.bigSliderView)
          
            
            let p = currentPoint.x - panStartPoint.x
            translation.x = p - old!
            
            old = p
            
            if((recognizer.view?.center.x)! + translation.x + self.innerSliderView.frame.size.width/2 >= self.bigSliderView.frame.size.width-8)
            {
                recognizer.view?.center = CGPoint(x: CGFloat(self.bigSliderView.frame.size.width-8-self.innerSliderView.frame.size.width/2), y: CGFloat((recognizer.view?.center.y)!))
                flag = true
                
            }
            else if((recognizer.view?.center.x)! + translation.x - self.innerSliderView.frame.size.width/2 <= 8)
            {
                recognizer.view?.center = CGPoint(x: CGFloat(8+self.innerSliderView.frame.size.width/2), y: CGFloat((recognizer.view?.center.y)!))
                flag = false
            }
            else
            {
                recognizer.view?.center = CGPoint(x: CGFloat((recognizer.view?.center.x)! + translation.x), y: CGFloat((recognizer.view?.center.y)!))
                flag = true
                
            }
            
        }
        if recognizer.state == .ended {
            
            if(flag == false)
            {
                isEndingOfShift = true
                recognizer.view?.center = CGPoint(x: CGFloat(8+self.innerSliderView.frame.size.width/2), y: CGFloat((recognizer.view?.center.y)!))
                self.innerSliderView.center = CGPoint(x: CGFloat(8+self.innerSliderView.frame.size.width/2), y: CGFloat((recognizer.view?.center.y)!))
                
                self.rightInnerSliderView.center =  CGPoint(x: CGFloat(self.bigSliderView.frame.size.width-8-self.innerSliderView.frame.size.width/2), y: CGFloat((recognizer.view?.center.y)!))
                
                self.innerSliderView.isHidden = false
                self.rightInnerSliderView.isHidden = true
                self.bigSliderView.backgroundColor = UIColor.init(hexString: colorExtension.START_COLOR)
                
                locationManager.stopUpdatingLocation()
                locationManager.stopUpdatingHeading()
                startingAppForFirstTime = true
                endDate = Date()
                let duration: String = calculateDuration(startDate!, secondDate: endDate!)
                timeLabel.text = duration
                upperView.isHidden = false
                swipeLabel.text = String_Globals.END_SHIFT_TEXT
                
                let title = String_Globals.END_TITLE
                addAnnotationsToMap(newLocation!,title)
                
                let point = MKPointAnnotation()
                point.coordinate = (newLocation?.coordinate)!
                point.title = String_Globals.END_TITLE
                point.subtitle = String_Globals.SUBTITLE
                mapView.addAnnotation(point)
                
            }
            else
            {
                recognizer.view?.center = CGPoint(x: CGFloat(self.bigSliderView.frame.size.width-8-self.innerSliderView.frame.size.width/2), y: CGFloat((recognizer.view?.center.y)!))
                
            }
         
         swipeLabel.isHidden = false
        }
    }
    
//    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//        <#code#>
//    }
//    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let region: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(locations.last!.coordinate, 800, 800)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
        
        if(startingAppForFirstTime == true)
        {
            oldLocation = locations.last
            startingAppForFirstTime = false;
            let title = String_Globals.START_TITLE
            addAnnotationsToMap(oldLocation!, title)
        }
        else
        {
            oldLocation = newLocation
        
        }
        
            newLocation = locations.last
        
        if let oldLocationNew = oldLocation as CLLocation?{
            let oldCoordinates = oldLocationNew.coordinate
            let newCoordinates = newLocation?.coordinate
            let area:[CLLocationCoordinate2D] = [oldCoordinates, newCoordinates!]
           let polyline =  MKPolyline(coordinates: area, count: area.count)
            mapView.add(polyline)
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (overlay is MKPolyline) {
            let pr = MKPolylineRenderer(overlay: overlay)
            pr.strokeColor = UIColor.blue
            pr.lineWidth = 5
            return pr
        }
        return MKPolylineRenderer()
        
    }
   
    func calculateDuration(_ oldTime: Date, secondDate currentTime: Date) -> String {
        let date1: Date? = oldTime
        let date2: Date? = currentTime
        let secondsBetween: TimeInterval? = date2?.timeIntervalSince(date1!)
        let hh: Int = Int(secondsBetween!) / (60 * 60)
        var rem: Double = fmod(secondsBetween!, (60 * 60))
        let mm: Int = Int(rem) / 60
        rem = fmod(rem, 60)
        let ss: Int = Int(rem)
        let str = String(format: "%02dh:%02dm:%02ds", hh, mm, ss)
        return str
    }
    
    
}
