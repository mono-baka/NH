//
//  ViewController.swift
//  hello
//
//  Created by Kosei Miyata on 2019/06/30.
//  Copyright © 2019 aaa. All rights reserved.
//

import UIKit            //
import CoreLocation     //for GPS and magnetic sensor
import Foundation       //for HTTP json
import Speech           //for speech converts to text


class ViewController: UIViewController,
    CLLocationManagerDelegate,//set GPS delegate
    UITextFieldDelegate//set UIField deligate
{
    //user user interface parameter
    @IBOutlet weak var console: UITextView!
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var send_text: UITextField!
    //user locate global parametr
    var locationManager : CLLocationManager!
    //user speech initlize
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!;
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?;
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine();
    ///user obserber timer object
    var timer = Timer();
    //user disp debug console message parameter
    var disp = "debug console";
    //user parameter
    var uuid = "xxx";
    var latitude = "000";
    var longitude = "000";
    var compass = "000";
    var message = "000";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //user set callback function when finish this app
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ViewController.finish(_:)),
            name: UIApplication.willTerminateNotification,
            object: nil)
        
        //user set send text delegate
        send_text.delegate = self;
        //send_text.keyboardType = .asciiCapable;//only ascii keyboard
        
        //user set uuid code
        self.uuid = NSUUID().uuidString;
        
        //user debug console init
        self.console.text = self.disp;
        console.isEditable = false;//disable edit
        console.isSelectable = false;//disable select
        info.lineBreakMode = .byWordWrapping;//set linebreak option
        info.numberOfLines = 0;//disable number of line
        
        //user locate init
        locationManager = CLLocationManager.init()
        locationManager.allowsBackgroundLocationUpdates = true;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 1;
        locationManager.delegate = self as? CLLocationManagerDelegate;
        //call function period of 1[degrees]
        locationManager.headingFilter = kCLHeadingFilterNone;
        locationManager.headingOrientation = .portrait;
        locationManager.startUpdatingHeading();
        
        //user ask permission state
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
        
        //user start speech
        try? start();
        
        //user obserber of period 1[sec]
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {(timer) in
            //user infomation send sheet
            var url_st = "https://script.google.com/macros/s/AKfycbwgaP67nbisXt1SXh-F-HfHsH7ZVaSAxAG84qIeC1Zy3t0FH3xi/exec"
            let url_parameter = "?uuid=" + self.uuid + "&latitude=" + self.latitude + "&longitude=" + self.longitude + "&compass=" + self.compass;
            url_st = url_st + url_parameter;
            self.get(url: url_st);
            self.console.text = self.disp;
        })
    }
    override func didReceiveMemoryWarning() {
        //memory warning!
        super.didReceiveMemoryWarning();
    }
    @objc func finish(_ notification: Notification?){
        self.message = "";
        var url_st = "https://script.google.com/macros/s/AKfycbwgaP67nbisXt1SXh-F-HfHsH7ZVaSAxAG84qIeC1Zy3t0FH3xi/exec";
        let url_parameter = "?uuid=" + self.uuid + "&longitude=" + self.longitude + "&latitude=" + self.latitude + "&compass=" + self.compass + "&message=" + self.message;
        url_st = url_st + url_parameter;
        post(url: url_st);
        let alert = UIAlertController(
            title: "disable app!",
            message: "",
            preferredStyle: UIAlertController.Style.alert);
        let okayButton = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.cancel,
            handler: nil);
        alert.addAction(okayButton);
        present(alert, animated: true, completion:  nil);
        print("[finish] app finished!" + url_st);
    }
    
    @IBAction func weather_load(_ sender: Any) {
    }
    func get(url urlString: String){
        guard let url = URLComponents(string: urlString) else {return}
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
    }
    @IBAction func post_button(_ sender: Any) {
        var url_st = "https://script.google.com/macros/s/AKfycbwgaP67nbisXt1SXh-F-HfHsH7ZVaSAxAG84qIeC1Zy3t0FH3xi/exec";
        let url_parameter = "?uuid=" + self.uuid + "&longitude=" + self.longitude + "&latitude=" + self.latitude + "&compass=" + self.compass + "&message=" + send_text.text!;
        url_st = url_st + url_parameter;
        print(url_st);
        post(url: url_st);
    }
    func post(url urlString: String){
        let url_enc = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed);
        var request = URLRequest(url: URL(string: url_enc!)!);
        request.httpMethod = "POST";
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
            if let data = data, let response = response {
                print(response);
                print(data);
            }
        })
        task.resume();
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
        self.info.text = "uuid:" + self.uuid+"\n";
        self.info.text?.append("latitude:"+self.latitude+"\n");
        self.info.text?.append("longitude:"+self.longitude+"\n");
        self.info.text?.append("compass:"+self.compass+"\n");
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        send_text.resignFirstResponder();
    }
    private func start() throws {
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: [])
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        self.recognitionRequest = recognitionRequest
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] (result, error) in
            guard let `self` = self else { return }
            var isFinal = false
            if let result = result {
                print(result.bestTranscription.formattedString)
                self.send_text.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        self.audioEngine.prepare()
        try? self.audioEngine.start()
    }
}


