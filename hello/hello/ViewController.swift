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

struct WeatherNews: Codable {
    let title: String
    let publicTime: String
    let forecasts: [Forecast]
    let location: WeatherLocation
    let description: WeatherDescription
}
struct Forecast: Codable {
    let dateLabel: String
    let telop: String
    let date: String
    let temperature: TemperatureCollection
    let image: WeatherImage
}
struct TemperatureCollection: Codable {
    let min: Temperature?
    let max: Temperature?
}
struct Temperature: Codable {
    let celsius: String
    let fahrenheit: String
}
struct WeatherImage: Codable {
    let width: Int
    let height: Int
    let title: String
    let url: String
}
struct WeatherLocation: Codable {
    let city: String
    let area: String
    let prefecture: String
}
struct WeatherDescription: Codable {
    let text: String
    let publicTime: String
}

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var latitude: UILabel!
    @IBOutlet weak var longitude: UILabel!
    @IBOutlet weak var compass: UILabel!
    @IBOutlet weak var console: UITextView!
    var locationManager : CLLocationManager!
    var disp = "debug console";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up UIStepper
        
        //user
        self.console.text = self.disp;
        console.isEditable = false;
        console.isSelectable = false;
        
        //user locate
        locationManager = CLLocationManager.init()
        locationManager.allowsBackgroundLocationUpdates = true;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 1;
        locationManager.delegate = self as? CLLocationManagerDelegate;
        //period of 1[degrees]
        locationManager.headingFilter = kCLHeadingFilterNone;
        locationManager.headingOrientation = .portrait;
        locationManager.startUpdatingHeading();
        
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
        let url_st =    "http://weather.livedoor.com/forecast/webservice/json/v1?city=090010"
        guard let url = URL(string: url_st) else {return}
        URLSession.shared.dataTask(with: url) { (data, responce, error) in
            if error != nil {
                self.disp = error!.localizedDescription;
            }
            let str_data = String(data: data!, encoding: .utf8)!
            let json = try! JSONDecoder().decode(WeatherNews.self, from: str_data.data(using: .utf8)!)
            self.disp = json.title + "\n" + json.description.text;
            }.resume()
        self.console.text = self.disp;
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location : CLLocation = locations.last!;
        self.latitude.text = "latitude: ".appendingFormat("%.6f", location.coordinate.latitude);
        self.longitude.text = "longitude: ".appendingFormat("%.6f", location.coordinate.longitude);
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //compass changing
        self.compass.text = "compass: ".appendingFormat("%.2f", newHeading.magneticHeading);
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //this function is called when any error
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //this function is called change permission
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


