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
import AVFoundation     //for text convert to speech


class ViewController: UIViewController,
    CLLocationManagerDelegate,      //set GPS delegate
    UITextFieldDelegate,            //set UIField delegate
    AVSpeechSynthesizerDelegate     //set Synthesizer delegate
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
 
    //user synthesizer init
    var speechSynthesizer = AVSpeechSynthesizer();
    var is_speaking = false;
    //user obserber timer object
    var timer = Timer();
    //user disp debug console message parameter
    var disp = "debug console";
    //user parameter
    var uuid = "xxx";
    var latitude = "000";
    var longitude = "000";
    var compass = "000";
    var message = "000";
    var re_uuid = "xxx";
    var re_latitude = "";
    var re_longitude = "";
    var re_compass = "";
    var re_message = "";
    var speech = "";
    var speech_not_changing_cnt = 0;
    var speech_buf = "";
    
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
        
        //user convert text to speech
        speechSynthesizer = AVSpeechSynthesizer();
        speechSynthesizer.delegate = self;
        
        //user locate init
        locationManager = CLLocationManager.init()
        locationManager.allowsBackgroundLocationUpdates = true;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 1;
        locationManager.delegate = self;// as? CLLocationManagerDelegate;
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
            //user calc distance and direction, disp
            if self.re_uuid != "xxx" {
                let dP:Double = Double(self.latitude)! - Double(self.re_latitude)!;
                let dR:Double = Double(self.longitude)! - Double(self.re_longitude)!;
                let P:Double = (Double(self.latitude)! + Double(self.re_latitude)!) / 2;
                let dir:Double = self.direction(dP_deg: dP, dR_deg: dR, aveP_deg: P);
                self.disp.append("\ndistance: " + String(self.distance(dP_deg: dP, dR_deg: dR, aveP_deg: P)));
                self.disp.append("\ndirection: " + String(dir));
                self.disp.append("\nmuki: " + self.udlr(dir: dir, com: Double(self.compass)!));
            }
            self.console.text = self.disp;
            //user update speech text
            if(self.speech != ""){
                self.send_text.text?.append(self.speech);
                self.speech = "";
                try? self.start();
            }
        })
    }
    override func didReceiveMemoryWarning() {
        //memory warning!
        super.didReceiveMemoryWarning();
    }
    func speak(speech_text: String) {
        self.is_speaking = true;
        //audio session category reset
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory(.playAndRecord, mode: .voiceChat);
        let utterrance = AVSpeechUtterance(string: speech_text);
        utterrance.voice = AVSpeechSynthesisVoice(language: "ja-JP");
        utterrance.rate = 0.5;
        utterrance.pitchMultiplier = 0.5;
        utterrance.preUtteranceDelay = 0.2;
        utterrance.volume = 1;//0~1
        self.speechSynthesizer.speak(utterrance);
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.view.backgroundColor = UIColor.red;
    }
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("[synthesizer]:finish speaking");
        self.is_speaking = false;
        self.view.backgroundColor = UIColor.white;
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
    func get(url urlString: String){
        guard let url = URLComponents(string: urlString) else {return}
        let task = URLSession.shared.dataTask(with: url.url!) { (data, responce, error) in
            if error != nil {
                self.disp = error!.localizedDescription;
            }
            guard let _data: Data = data else { return }
            //let str_data = String(data: _data, encoding: .utf8)!
            //user print [json]: get data
            //print("[json]:" + "\n" + str_data + "\n");
            struct position: Codable {
                let uuid: String         //Reserved
                let latitude: String    //Ido
                let longitude: String    //Keido
                let compass: String     //Houi
                let message: String     //Onseininshiki
            }
            let json: [position] = try! JSONDecoder().decode([position].self, from: _data);//str_data.data(using: .utf8)!)
            self.disp = json[0].uuid + "\n" + json[0].latitude + "\n" + json[0].longitude + "\n" + json[0].compass + "\n" + json[0].message;
            self.re_uuid = "" + json[0].uuid;
            self.re_latitude = json[0].latitude;
            self.re_longitude = json[0].longitude;
            self.re_compass = json[0].compass;
            if(json[0].message != "xxx")&&(json[0].message != self.re_message){
                self.speak(speech_text: json[0].message);
            }
            self.re_message = json[0].message;
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
        self.view.backgroundColor = UIColor.cyan;
        let url_enc = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed);
        var request = URLRequest(url: URL(string: url_enc!)!);
        request.httpMethod = "POST";
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let dispatchGroup = DispatchGroup();
        dispatchGroup.enter();
        let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
            if let data = data, let response = response {
                print(response);
                print(data);
                dispatchGroup.leave();
            }
        })
        task.resume();
        dispatchGroup.notify(queue: .main){
            self.view.backgroundColor = UIColor.white;
        }
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
        recognitionRequest.shouldReportPartialResults = true;
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] (result, error) in
            guard let `self` = self else { return }
            var isFinal = false;
            if let result = result {
                print(result.bestTranscription.formattedString)
                if(self.speech_buf == result.bestTranscription.formattedString){
                    self.speech_not_changing_cnt += 1;
                }
                self.speech_buf = result.bestTranscription.formattedString
                isFinal = result.isFinal;
                if(0 < self.speech_not_changing_cnt){
                    //not change?
                    self.speech = self.speech_buf;
                    self.speech_not_changing_cnt = 0;
                    //reset
                    self.recognitionTask?.cancel();
                    self.recognitionTask?.finish();
                    self.audioEngine.stop();
                }
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                self.audioEngine.inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        if !self.is_speaking {
            self.audioEngine.prepare()
            try? self.audioEngine.start()
        }
    }
    func distance(dP_deg: Double, dR_deg: Double, aveP_deg: Double) -> Double {
        let dP = dP_deg * Double.pi / 180;
        let dR = dR_deg * Double.pi / 180;
        let P = aveP_deg * Double.pi / 180;
        let M = 6334834 / sqrt(pow(1 - 0.006674 * sin(P) * sin(P), 3));
        let N = 6377397 / sqrt(1 - 0.006674 * sin(P) * sin(P));
        return(sqrt( pow(M * dP, 2) + pow(N * cos(P) * dR, 2)));
    }
    func direction(dP_deg: Double, dR_deg: Double, aveP_deg: Double) -> Double {
        let dP = dP_deg * Double.pi / 180;
        let dR = dR_deg * Double.pi / 180;
        let P = aveP_deg * Double.pi / 180;
        let M = 6334834 / sqrt(pow(1 - 0.006674 * sin(P) * sin(P), 3));
        let N = 6377397 / sqrt(1 - 0.006674 * sin(P) * sin(P));
        //calc angle
        var angle = atan((N * cos(P) * dR) / (M * dP));
        if(dP < 0){
            if(angle < 0){
                angle = 2 * Double.pi + angle;
            }
        }
        else{
            angle = angle + Double.pi;
        }
        return angle * 180 / Double.pi;
    }
    func udlr(dir: Double, com: Double) -> String {
        //up = 0, down = 1, right = 2, left = 3
        let d:Double = dir - com;
        if((45 * 7 < d) && (d < 45 * 1)){
            return("front");
        }
        if((45 * 1 < d) && (d < 45 * 3)){
            return("right");
        }
        if((45 * 3 < d) && (d < 45 * 5)){
            return("rear");
        }
        if((45 * 5 < d) && (d < 45 * 7)){
            return("left");
        }
        return("null");
    }
}
