//
//  ViewController.swift
//  hello
//
//  Created by Kosei Miyata on 2019/06/30.
//  Copyright © 2019 aaa. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    //user user interface
    @IBOutlet weak var console: UITextView!
    //user locate
    var locationManager : CLLocationManager!
    //user debug console
    var disp = "debug console";
    //user parameter
    var uuid = "xxx";
    var longitude = "000";
    var latitude = "000";
    var compass = "000";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up UIStepper
        
        //user uuid get
        self.uuid = NSUUID().uuidString;
        
        //user debug console init
        self.console.text = self.disp;
        console.isEditable = false;
        console.isSelectable = false;
        
        //user locate init
        locationManager = CLLocationManager.init()
        locationManager.allowsBackgroundLocationUpdates = true;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 1;
        locationManager.delegate = self as? CLLocationManagerDelegate;
        //period of 1[degrees]
        locationManager.headingFilter = kCLHeadingFilterNone;
        locationManager.headingOrientation = .portrait;
        locationManager.startUpdatingHeading();
        
        //user permission state
        let status = CLLocationManager.authorizationStatus()
        if(status == .notDetermined){
            print("Don't choose permission");
            locationManager.requestAlwaysAuthorization();
        }else if(status == .restricted){
            print("The function is limited");
        }else if(status == .denied){
            print("Not allowed");
        }else if(status == .authorizedWhenInUse){
            print("Allowed only while using this application");
            locationManager.startUpdatingLocation();
        }else if(status == .authorizedAlways){
            print("Allowed always");
            locationManager.startUpdatingLocation();
        }
    }
    override func didReceiveMemoryWarning() {
        //maybe, this function is called when dipose memory?
        super.didReceiveMemoryWarning();
    }
    @IBAction func weather_load(_ sender: Any) {
        //user api url(=google spreadsheet)
        var url_st = "https://script.google.com/macros/s/AKfycbwgaP67nbisXt1SXh-F-HfHsH7ZVaSAxAG84qIeC1Zy3t0FH3xi/exec"
        let url_parameter = "?uuid=" + self.uuid + "&longitude=" + self.longitude + "&latitude=" + self.latitude + "&compass=" + self.compass;
        url_st = url_st + url_parameter;
        print(url_st);
        guard let url = URLComponents(string: url_st) else {return}
        let task = URLSession.shared.dataTask(with: url.url!) { (data, responce, error) in
            if error != nil {
                self.disp = error!.localizedDescription;
            }
            guard let _data: Data = data else { return }
            let str_data = String(data: _data, encoding: .utf8)!
            //user print [json]: get data
            print("[json]:" + "\n" + str_data + "\n");
            struct position: Codable {
                let uuid: String         //Reserved
                let latitude: String    //Ido
                let longitude: String    //Keido
                let compass: String     //Houi
                let message: String     //Onseininshiki
            }
            let json: [position] = try! JSONDecoder().decode([position].self, from: _data);//str_data.data(using: .utf8)!)
            self.disp = json[0].uuid + "\n" + json[0].latitude + "\n" + json[0].longitude + "\n" + json[0].compass + "\n" + json[0].message;
            }
            task.resume()
        self.console.text = self.disp;
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //user locate callback freq:1[Hz]
        let location : CLLocation = locations.last!;
        self.latitude = "".appendingFormat("%.6f", location.coordinate.latitude);
        self.longitude = "".appendingFormat("%.6f", location.coordinate.longitude);
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //user compass changing
        self.compass = "".appendingFormat("%.2f", newHeading.magneticHeading);
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //user this function is called when any error
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //user this function is called change permission
        if(status == .restricted){
            print("The function is limited");
        }else if(status == .denied){
            print("Not allowed");
        }else if(status == .authorizedWhenInUse){
            print("Allowed only while using this application");
            locationManager.startUpdatingLocation();
        }else if(status == .authorizedAlways){
            print("Allowed always");
            locationManager.startUpdatingLocation();
        }
    }
}


