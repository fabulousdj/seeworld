//
//  ViewController.swift
//  SeeWorld
//
//  Created by Raphael on 11/2/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import AVFoundation
import Speech


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate, ConversationResponseHandlerDelegate, SimpleResponseHandlerDelegate {
    
    /********************* For basicView *********************/
    let textSpeechConversion = TextSpeechConversionClient()
    
    /********************** For mapView **********************/
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let mapModel = MapClient()
    
    /********************** For textView *********************/
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var microphoneButton: UIButton!
    let textModel = TextModel()
    
    //let longPressGesture = UILongPressGestureRecognizer(target: self, action: Selector("longPressCancelButton:"))
    
    private let conversation = ConversationClient()
    private let weatherModel = WeatherClient()
    private let timeModel = TimeClient()
    private let userReviewModel = UserReviewClient()
    
    private var latitude : Float = 0.0
    private var longitude : Float = 0.0
    
    private var response : String = ""
    private var isSpeakerAccessEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        microphoneButton.isEnabled = false
        textSpeechConversion.speechRecognizer.delegate = self
        textSpeechConversion.speechSynthesizer.delegate = self
        
        // Delegate
        conversation.delegate = self
        weatherModel.delegate = self
        timeModel.delegate = self
        
        // Check the microphone
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isSpeakerAccessEnabled = false
            
            switch authStatus {
            case .authorized:
                isSpeakerAccessEnabled = true
            case .denied:
                isSpeakerAccessEnabled = false
                print("User denied access to speech recognition")
            case .restricted:
                isSpeakerAccessEnabled = false
                print("Speech recognition restricted on this device")
            case .notDetermined:
                isSpeakerAccessEnabled = false
                print("Speech recognition not yet authorized")
            }
            // Make the button works
            OperationQueue.main.addOperation() {
                self.isSpeakerAccessEnabled = isSpeakerAccessEnabled
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ConversationContext.Instance.reset()
        self.startConversation()
    }
    
    // Your location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        mapModel._lng = Double(location.coordinate.longitude)
        mapModel._lat = Double(location.coordinate.latitude)
        
        // pass the value from map to text
        struct glovalVariable {
            static var userName = String();
        }
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        
        self.mapView.setRegion(region, animated: true)
        self.mapView.showsUserLocation = true
        
        //stop updating location to save battery life
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func microphoneTapped(_ sender: AnyObject) {
        if self.textSpeechConversion.audioEngine.isRunning {
            self.textSpeechConversion.audioEngine.stop()
            self.textSpeechConversion.recognitionRequest?.endAudio()

            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                try audioSession.setMode(AVAudioSessionModeDefault)
            } catch {
                print("audioSession properties weren't set because of an error.")
            }
            let userInput = self.textView.text
            ConversationContext.Instance.input = userInput!
            self.startConversation()
        } else {
            self.textSpeechConversion.startRecording(textView: self.textView, microphoneButton: self.microphoneButton)
        }
    }
    
    private func startConversation() {
        self.microphoneButton.isEnabled = false
        conversation.sendMessage()
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer,
                          availabilityDidChange available: Bool) {
        if available {
            if self.isSpeakerAccessEnabled {
                microphoneButton.isEnabled = true
            }
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
//                           didStart utterance: AVSpeechUtterance) {
//        self.microphoneButton.isEnabled = false
//    }
//
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
//                           didFinish utterance: AVSpeechUtterance) {
//        if self.isSpeakerAccessEnabled {
//            self.microphoneButton.isEnabled = true
//        }
//    }
    
    func handleConversationResponse(result: [String : Any]) {
        let systemContext = result["system"] as! [String : Any]
        let nodeName = result["nodeName"] as! String
        let responseArray = result["response"] as! [String]
        
        self.response = ""
        for singleResponse : String in responseArray {
            self.response += singleResponse + "\n"
        }
        
        ConversationContext.Instance.systemContext = systemContext
        switch nodeName {
        case "Get Review":
            //evaluate “valid_review”
            break;
        case "Weather":
            //return current weather
            let currentCoordinate = mapModel.getCurrentCoordinate()
            weatherModel.retrieveWeatherData(self.textView, currentCoordinate.latitude, currentCoordinate.longitude)
            break;
        case "Time":
            //return current time
            self.timeModel.retrieveCurrentTime()
            break;
        case "Choose Method":
            //get “method” (walk, public, uber, phone)
            break;
        case "Destination":
            // get destination
            break;
        case "Info":
            //return eta (transportation method and review summary)
            break;
        case "Close App":
            UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
            break;
        default:
            self.handleSimpleResponse(response: response, shouldAppendOriginalResponse: false)
            break;
        }
    }
    
    func handleSimpleResponse(response: String, shouldAppendOriginalResponse : Bool) {
        var response = response
        if shouldAppendOriginalResponse {
            response += "\n" + self.response
        }
        DispatchQueue.main.async {
            self.textView.text = response
            self.textSpeechConversion.textToSpeech(response)
            if self.isSpeakerAccessEnabled {
                self.microphoneButton.isEnabled = true
            }
        }
    }
}

