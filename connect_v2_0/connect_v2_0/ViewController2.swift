//
//  ViewController2.swift
//  connect_v2_0
//
//  Created by Kosei Miyata on 2019/08/25.
//  Copyright © 2019 fumiya_tellus@yahoo.co.jp. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation
import Speech
import AVFoundation

class ViewController2: UIViewController,
    CLLocationManagerDelegate,
    UITextFieldDelegate,
    AVSpeechSynthesizerDelegate
{
    
    @IBOutlet weak var recieve: UITextView!
    @IBOutlet weak var send: UITextField!
    @IBOutlet weak var fr: UILabel!
    @IBOutlet weak var ri: UILabel!
    @IBOutlet weak var re: UILabel!
    @IBOutlet weak var le: UILabel!
    //locate init
    var locationManager : CLLocationManager!;
    //speech init
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "ja-JP"))!;
    private var recognitionRequest : SFSpeechAudioBufferRecognitionRequest?;
    private var recognitionTask: SFSpeechRecognitionTask?;
    private let audioEngine = AVAudioEngine();
    //synthesizer init
    var speechSynthesizer = AVSpeechSynthesizer();
    var is_speaking = false;
    //observer timer init
    var timer = Timer();
    //parameter
    var disp = "";
    var uuid = "";
    var latitude = "";
    var longitude = "";
    var compass = "";
    var message = "";
    var re_uuid = "xxx";
    var re_latitude = "";
    var re_longitude = "";
    var re_message = "";
    var speech_not_changing_cnt = 0;
    var speech_buf = "";
    var speech = "";
    var didfinish = false;

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(ViewController.finish(_:)),
            name: UIApplication.willTerminateNotification,
            object: nil);
        //send delegate
        send.delegate = self;
        
        //get uuid
        self.uuid = NSUUID().uuidString;
        //recieve text field init
        recieve.isEditable = false; //disable edit
        recieve.isSelectable = false;//disable select
        //AVSpeech Synthesizer init]
        speechSynthesizer = AVSpeechSynthesizer();
        speechSynthesizer.delegate = self;
        //locate init
        locationManager = CLLocationManager.init();
        locationManager.allowsBackgroundLocationUpdates = true;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.distanceFilter = 1;
        locationManager.delegate = self;
        locationManager.headingFilter = kCLHeadingFilterNone;
        locationManager.headingOrientation = .portrait;
        locationManager.startUpdatingHeading();
        //start location
        locationManager.startUpdatingLocation();
        
        //start recognizer
        try? recording();
        //say hello
        self.speak(speech_text: "きどうせいこう");
        
        //observer of period 1[sec]
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {(timer) in
            //user infomation send sheet
            var url_st = "https://script.google.com/macros/s/AKfycbwgaP67nbisXt1SXh-F-HfHsH7ZVaSAxAG84qIeC1Zy3t0FH3xi/exec"
            let url_parameter = "?uuid=" + self.uuid + "&latitude=" + self.latitude + "&longitude=" + self.longitude + "&compass=" + self.compass;
            url_st = url_st + url_parameter;
            if(!self.didfinish){
                self.get(url: url_st);
            }
            //user calc distance and direction, disp
            if self.re_uuid != "xxx" {
                let dP:Double = Double(self.latitude)! - Double(self.re_latitude)!;
                let dR:Double = Double(self.longitude)! - Double(self.re_longitude)!;
                let P:Double = (Double(self.latitude)! + Double(self.re_latitude)!) /   2;
                self.disp.append("\ndistance: " + String(self.distance(dP_deg: dP, dR_deg: dR, aveP_deg: P)));
                self.disp.append("\n" + self.message);
                let dir:Double = self.direction(dP_deg: dP, dR_deg: dR, aveP_deg: P);
                if(self.is_speaking){
                    switch(self.udlr(dir: dir, com: Double(self.compass)!)){
                    case "front":
                        self.fr.backgroundColor = UIColor.green;
                        break;
                    case "right":
                        self.ri.backgroundColor = UIColor.blue;
                        break;
                    case "rear":
                        self.re.backgroundColor = UIColor.gray;
                        break;
                    case "left":
                        self.le.backgroundColor = UIColor.yellow;
                        break;
                    default:
                        break;
                    }
                }
            }
            self.recieve.text = self.disp;
            self.disp = "";
            //user update speech text
            if(self.speech != ""){
                if(self.speech=="オーバー"){
                    var url_st = "https://script.google.com/macros/s/AKfycbwgaP67nbisXt1SXh-F-HfHsH7ZVaSAxAG84qIeC1Zy3t0FH3xi/exec";
                    let url_parameter = "?uuid=" + self.uuid + "&longitude=" + self.longitude + "&latitude=" + self.latitude + "&compass=" + self.compass + "&message=" + self.send.text!;
                    url_st = url_st + url_parameter;
                    self.post(url: url_st);
                    self.send.text = "";
                    self.speech = "";
                }
                self.send.text?.append(self.speech);
                if(self.speech=="削除"){
                    self.send.text = "";
                }
                self.speech = "";
                try? self.recording();
            }
        })
    }
    @IBAction func button(_ sender: Any) {
        var url_st = "https://script.google.com/macros/s/AKfycbwgaP67nbisXt1SXh-F-HfHsH7ZVaSAxAG84qIeC1Zy3t0FH3xi/exec";
        let url_parameter = "?uuid=" + self.uuid + "&longitude=" + self.longitude + "&latitude=" + self.latitude + "&compass=" + self.compass + "&message=" + send.text!;
        url_st = url_st + url_parameter;
        post(url: url_st);
        self.send.text = "";
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
        var d:Double = dir - com;
        if(d<0){
            d = 360 + d;
        }
        if(((0 < d) && (d < 45 * 1)) || ((45 * 7 < d) && (d < 360))){
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
    func get(url urlString: String){
        guard let url = URLComponents(string: urlString) else {return}
        let task = URLSession.shared.dataTask(with: url.url!) { (data, responce, error) in
            if error != nil {
                print(error!.localizedDescription);
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
            self.re_latitude = json[0].latitude;
            self.re_longitude = json[0].longitude;
            if(json[0].message != "xxx")&&(json[0].message != self.re_message){
                self.speak(speech_text: json[0].message);
            }
            self.re_uuid = json[0].uuid;
            self.re_latitude = json[0].latitude;
            self.re_longitude = json[0].longitude;
            self.re_message = json[0].message;
        }
        task.resume()
    }
    func post_start() {
        var url_st = "https://script.google.com/macros/s/AKfycbwgaP67nbisXt1SXh-F-HfHsH7ZVaSAxAG84qIeC1Zy3t0FH3xi/exec";
        let url_parameter = "?uuid=" + self.uuid + "&longitude=" + self.longitude + "&latitude=" + self.latitude + "&compass=" + self.compass + "&message=" + send.text!;
        url_st = url_st + url_parameter;
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
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //user this function is called when any error
    }
    private func recording() throws {
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
    func speak(speech_text: String) {
        self.recognitionTask?.cancel();
        self.recognitionTask?.finish();
        self.audioEngine.stop();
        self.is_speaking = true;
        //audio session category reset
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker);
        try! audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker);
        try! audioSession.setActive(true);
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
        self.fr.backgroundColor = UIColor.white;
        self.ri.backgroundColor = UIColor.white;
        self.le.backgroundColor = UIColor.white;
        self.re.backgroundColor = UIColor.white;
        try? self.recording();
    }
    @objc func finish(_ notification: Notification?){
        self.didfinish = true;
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        send.resignFirstResponder();
    }
}
