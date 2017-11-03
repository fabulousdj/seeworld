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


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, SFSpeechRecognizerDelegate{
    
    /* -------------------------------------------View ------------------------------------------- */
    /********************* For basicView *********************/
    let basicModel = BaiscFuncModel()
    
    /********************** For mapView **********************/
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let mapModel = MapModel()
    
    /********************** For textView *********************/
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var microphoneButton: UIButton!
    let textModel = TextModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /********************** For mapView **********************/
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        /********************** For textView *********************/
        microphoneButton.isEnabled = false
        basicModel.speechRecognizer.delegate = self
        textView.isEditable = false
        
        // Check the microphone
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            // Make the button works
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
    }
    
    /* --------------------------------------- Controller --------------------------------------- */
    /********************** For mapView **********************/
    // Your location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        let location = locations[0]
        mapModel._lon = Double(location.coordinate.longitude)
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
    
    /********************** For textView **********************/
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
    // The main func, which control the microphone
    @IBAction func microphoneTapped(_ sender: AnyObject) {
        if self.basicModel.audioEngine.isRunning {
            self.basicModel.audioEngine.stop()
            self.basicModel.recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setTitle("Start", for: .normal)
            self.basicModel.input = self.basicModel.bestString
            
            if (self.textModel.bool) {
                self.textModel.claasify(self.basicModel.input, self.textModel.state, _textView: textView, _mapView: mapView)
            }
            else {
                self.textModel.state = "sw_trans_method_selection"
                self.textModel.claasify(self.basicModel.input, self.textModel.state, _textView: textView, _mapView: mapView)
            }
        } else {
            if (self.textModel.bool) {
                self.textView.text = "What is your destination?"
                self.basicModel.testToSpeech("What is your destination?")
            }
            else {
                self.textView.text = "Which transport do you prefer?"
                self.basicModel.testToSpeech("Which transport do you prefer?")
            }
            
            // Delay the speech to text
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(2*NSEC_PER_SEC))/Double(NSEC_PER_SEC)) {
                self.basicModel.startRecording(_textView: self.textView, _microphoneButton: self.microphoneButton)
            }
            microphoneButton.setTitle("Stop", for: .normal)
        }
    }
    
}

