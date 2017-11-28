//
//  TextModel.swift
//  SeeWorld
//
//  Created by Raphael on 11/2/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation
import Alamofire
import MapKit
import CoreLocation
import UIKit

class TextModel {
    let basicModel = BaiscFuncModel()
    let mapModel = MapModel()
    let addressModel = AddressModel()
    let googleSearcModel = CallFuncModel()
    var bool: Bool = true
    var state = "sw_waiting_for_destination"
    
    // NLC Func
    func claasify(_ input: String, _ state: String, _textView: UITextView, _mapView: MKMapView) {
        let apiEndpoint: String = "http://seeworld-api-test.mybluemix.net/seeworld/api/v1/natural-language-processing/classify";
        Alamofire.request(apiEndpoint, method: .get, parameters: ["input": input, "state": state])
            .responseJSON { response in
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling GET on /seeworld/api/v1/natural-language-processing/classify")
                    print(response.result.error!)
                    return
                }
                
                // make sure we got some JSON since that's what we expect
                guard let json = response.result.value as? [String: Any] else {
                    print("didn't get classify object as JSON from API")
                    print("Error: \(String(describing: response.result.error))")
                    return
                }
                
                // get and print the title
                guard let classifiedResult = json["value"] as? String else {
                    print("Could not get classified result from JSON")
                    return
                }
                
                self.respondToClassifiedResult(classifiedResult, _textView: _textView, _mapView: _mapView)
        }
    }
    
    // getReview Func
    func getReview(_textView: UITextView) {
        let parameters: [String: String] = [
            "name": self.addressModel.getCoreData(name: "name"),
            "address": self.addressModel.getCoreData(name: "address"),
            "city": self.addressModel.getCoreData(name: "city"),
            "state": self.addressModel.getCoreData(name: "state"),
            "country": "US"
        ]
        
        let apiEndpoint: String = "http://seeworld-api-test.mybluemix.net/seeworld/api/v1/user-reviews/get-insights";
        
        Alamofire.request(apiEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON { response in
                switch(response.result) {
                case .success(_):
                    if let result = response.result.value {
                        let JSON = result as! NSDictionary
                        let value = JSON.object(forKey: "value") as! NSDictionary
                        let count = value.object(forKey: "count") as! Int
                        let negative = value.object(forKey: "negative") as! String
                        let neutral = value.object(forKey: "neutral") as! String
                        let positive = value.object(forKey: "positive") as! String
                        
                        var resultOutput = "We get " + String(count) + "review(s）for this destination: "
                        resultOutput += negative + " negative review, "
                        resultOutput += neutral + " neutral review, "
                        resultOutput += positive + " positive review."
                        
                        _textView.text = resultOutput
                        self.basicModel.testToSpeech(resultOutput)
                    }
                    break
                    
                case .failure(_):
                    print("There is an error")
                    break
                }
        }
    }
    
    
    //    func sendMessage(_textView: UITextView) {
    //        let parameters: [String: String] = [
    //            "name": self.addressModel.getCoreData(name: "name"),
    //            "address": self.addressModel.getCoreData(name: "address"),
    //            "city": self.addressModel.getCoreData(name: "city"),
    //            "state": self.addressModel.getCoreData(name: "state"),
    //            "country": "US"
    //        ]
    //
    //        let apiEndpoint: String = "http://seeworld-api-test.mybluemix.net/seeworld/api/v1/user-reviews/get-insights";
    //
    //        Alamofire.request(apiEndpoint, method: .post, parameters: parameters, encoding: JSONEncoding.default)
    //            .responseJSON { response in
    //                switch(response.result) {
    //                case .success(_):
    //                    if let result = response.result.value {
    //                        let JSON = result as! NSDictionary
    //                        let value = JSON.object(forKey: "value") as! NSDictionary
    //                        let count = value.object(forKey: "count") as! Int
    //                        let negative = value.object(forKey: "negative") as! String
    //                        let neutral = value.object(forKey: "neutral") as! String
    //                        let positive = value.object(forKey: "positive") as! String
    //
    //                        var resultOutput = "We get " + String(count) + "review(s）for this destination: "
    //                        resultOutput += negative + " negative review, "
    //                        resultOutput += neutral + " neutral review, "
    //                        resultOutput += positive + " positive review."
    //
    //                        _textView.text = resultOutput
    //                        self.basicModel.testToSpeech(resultOutput)
    //                    }
    //                    break
    //
    //                case .failure(_):
    //                    print("There is an error")
    //                    break
    //                }
    //        }
    //    }
    //
    
    
    
    // The Oupt Results by NLC
    func respondToClassifiedResult(_ classifiedResult: String, _textView: UITextView, _mapView: MKMapView) {
        
        //self.textView.text.append("\n" + classifiedResult)
        switch classifiedResult {
        case "time":
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
            let dateInFormat = dateFormatter.string(from: Date())
            _textView.text = ("The time is " + dateInFormat)
            self.basicModel.testToSpeech("The time is " + dateInFormat)
            break
            
        case "temperature":
            self.mapModel.currentWeather(_textView)
            break
            
        case "location":
            self.bool = false
            
            // Google Search
            self.googleSearcModel.googleSearch(_textView, _mapView)
            
//            // Get the ETA
//            self.mapModel.searchPlace(_textView, _mapView)
            
            // DO NOT DELETE THESE TWO LINES
            /********************************************/
            _ = self.addressModel.getCoreData(name: "lat")
            _ = self.addressModel.getCoreData(name: "lon")
            /********************************************/
            
            // test case, can delete
            /********************************************/
            self.mapModel.makeCall(_textView)
            /********************************************/
            
            // Get Review
            //            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3*NSEC_PER_SEC))/Double(NSEC_PER_SEC)) {
            //                self.getReview(_textView: _textView)
            //            }
            //            _textView.text = ("You can leave review after you leave the destination")
            //            self.basicModel.testToSpeech("You can leave review after you leave the destination")
            break
            
        case "uber":
            _textView.text = "You choose Uber, We We will redirect to the Uber"
            self.basicModel.testToSpeech("You choose Uber, We will leave the app")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3*NSEC_PER_SEC))/Double(NSEC_PER_SEC)) {
                let myLocation = CLLocationCoordinate2D(latitude: self.mapModel._latEnd, longitude: self.mapModel._lonEnd)
                self.mapModel.openInMapsTransit(coord: myLocation)
            }
            break
            
        case "walk":
            // Open Apple Map
            _textView.text = "You choose walk, We will redirect to the Apple app"
            self.basicModel.testToSpeech("You choose walk, We will leave the app")
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3*NSEC_PER_SEC))/Double(NSEC_PER_SEC)) {
                let myLocation = CLLocationCoordinate2D(latitude: self.mapModel._latEnd, longitude: self.mapModel._lonEnd)
                self.mapModel.openInMapsTransit(coord: myLocation)
            }
            break
            
        case "public transportation":
            // Open Apple Map
            _textView.text = "You choose bus, We will redirect to the Apple app"
            self.basicModel.testToSpeech("You choose bus, We will leave the app")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(3*NSEC_PER_SEC))/Double(NSEC_PER_SEC)) {
                let myLocation = CLLocationCoordinate2D(latitude: self.mapModel._latEnd, longitude: self.mapModel._lonEnd)
                self.mapModel.openInMapsTransit(coord: myLocation)
            }
            break
            
        default:
            _textView.text = "Sorry, Please speak again!"
            self.basicModel.testToSpeech("Sorry, Please speak again!")
            break
        }
    }
    
}

