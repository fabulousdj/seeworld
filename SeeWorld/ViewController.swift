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
import GooglePlaces
import AVFoundation
import Speech


class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, SFSpeechRecognizerDelegate, AVSpeechSynthesizerDelegate, ConversationResponseHandlerDelegate, TextResultHandlerDelegate, PlaceSearchResponseHandlerDelegate, AppExitResponseHandlerDelegate, UserReviewClientResponseHandlerDelegate, TravelInfoResponseHandlerDelegate, SubroutineFailureHandlerDelegate, ApplicationEnterForegroundDelegate {
    
    /********************* For basicView *********************/
    let textSpeechConversion = TextSpeechConversionClient()
    
    /********************** For mapView **********************/
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    let mapViewClient = MapViewClient()
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var microphoneButton: UIButton!
    
    private let conversationClient = ConversationClient()
    private let weatherClient = WeatherClient()
    private let timeClient = TimeClient()
    private let userReviewClient = UserReviewClient()
    private let appExitClient = AppExitClient()
    private let placeSearchClient = PlaceSearchClient()
    private let transportInfoClient = TransportInfoClient()
    private let appRedirectClient = AppRedirectClient()
    
    private var isSpeakerAccessEnabled = false
    private let subroutineCount : Int = 4
    
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
        conversationClient.delegate = self
        weatherClient.delegate = self
        timeClient.delegate = self
        placeSearchClient.delegate = self
        userReviewClient.delegate = self
        appExitClient.delegate = self
        transportInfoClient.delegate = self
        
        userReviewClient.subroutineCompletionDelegate = self
        transportInfoClient.subroutineCompletionDelegate = self
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.delegate = self
        
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

    // Your location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        mapViewClient.currentLongitude = Double(location.coordinate.longitude)
        mapViewClient.currentLatitude = Double(location.coordinate.latitude)
        
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
    
    @IBAction func microphoneTouchedDown(_ sender: Any) {
        if !self.textSpeechConversion.audioEngine.isRunning {
            self.textSpeechConversion.startRecording(textView: self.textView, microphoneButton: self.microphoneButton)
        }
    }
    
    @IBAction func microphoneTouchedUp(_ sender: Any) {
        if self.textSpeechConversion.audioEngine.isRunning {
            self.textSpeechConversion.audioEngine.stop()
            self.textSpeechConversion.recognitionRequest?.endAudio()
            self.textSpeechConversion.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
            let userInput = self.textView.text
            AppContext.Instance.input = userInput!
            self.startConversation()
        }
    }
    
    private func startConversation() {
        self.microphoneButton.isEnabled = false
        conversationClient.sendMessage()
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
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer,
                           didFinish utterance: AVSpeechUtterance) {
        if AppContext.Instance.canStartNewConversation {
            UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
        }
    }
    
    func prepareForApplicationEnterForeground() {
        if (AppContext.Instance.canStartNewConversation) {
            // Map
            mapView.annotations.forEach {
                if !($0 is MKUserLocation) {
                    mapView.removeAnnotation($0)
                }
            }
            self.locationManager.startUpdatingLocation()
            // Conversation
            AppContext.Instance.canStartNewConversation = false
            AppContext.Instance.reset()
            self.startConversation()
        } else if (AppContext.Instance.isCalling) {
            AppContext.Instance.isCalling = false
            self.startConversation()
        }
    }
    
    func handleConversationResult(result: [String : Any]) {
        let systemContext = result["system"] as! [String : Any]
        let nodeName = result["nodeName"] as! String
        let input = result["input"] as! String
        let responseArray = result["response"] as! [String]
        
        var responseText = ""
        for singleResponseText : String in responseArray {
            responseText += singleResponseText + "\n"
        }
        AppContext.Instance.responseText = responseText
        AppContext.Instance.systemContext = systemContext
        switch nodeName {
        case ConversationActions.CANCEL.rawValue:
            mapView.annotations.forEach {
                if !($0 is MKUserLocation) {
                    mapView.removeAnnotation($0)
                }
            }
            self.locationManager.startUpdatingLocation()
            AppContext.Instance.reset()
            AppContext.Instance.systemContext = systemContext
            self.handleTextResult(result: responseText)
            break
        case ConversationActions.EVAL_REVIEW.rawValue:
            //evaluate “valid_review”
            break
        case ConversationActions.GET_WEATHER.rawValue:
            //return current weather
            let currentCoordinate = mapViewClient.getCurrentCoordinate()
            weatherClient.retrieveWeatherData(self.textView, currentCoordinate.latitude, currentCoordinate.longitude)
            break
        case ConversationActions.GET_TIME.rawValue:
            //return current time
            self.timeClient.retrieveCurrentTime()
            break
        case ConversationActions.WALK.rawValue:
            self.handleTextResult(result: responseText)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3) ) {
                let destinationInfo = AppContext.Instance.destinationInfo
                if (destinationInfo != nil) {
                    let destGeoLocation = destinationInfo?.geoLocation
                    self.appRedirectClient.redirectToAppleMap(latitude: (destGeoLocation?.latitude)!, longitude: (destGeoLocation?.longitude)!, directionMode: MKLaunchOptionsDirectionsModeWalking)
                }
            }
            break
        case ConversationActions.TRANSIT.rawValue:
            self.handleTextResult(result: responseText)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3) ) {
                let destinationInfo = AppContext.Instance.destinationInfo
                if (destinationInfo != nil) {
                    let destGeoLocation = destinationInfo?.geoLocation
                    self.appRedirectClient.redirectToAppleMap(latitude: (destGeoLocation?.latitude)!, longitude: (destGeoLocation?.longitude)!, directionMode: MKLaunchOptionsDirectionsModeTransit)
                }
            }
            break
        case ConversationActions.UBER.rawValue:
            self.handleTextResult(result: responseText)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3) ) {
                let destinationInfo = AppContext.Instance.destinationInfo
                if (destinationInfo != nil) {
                    let destGeoLocation = destinationInfo?.geoLocation
                    self.appRedirectClient.redirectToUber(latitude: (destGeoLocation?.latitude)!, longitude: (destGeoLocation?.longitude)!)
                }
            }
            break
        case ConversationActions.CALL.rawValue:
            let destinationInfo = AppContext.Instance.destinationInfo
            if (destinationInfo != nil) {
                self.placeSearchClient.getPlaceDetail((destinationInfo?.placeId)!)
            }
            break
        case ConversationActions.EVAL_DEST.rawValue:
            //get destination
            self.handleTextResult(result: responseText)
            let currentCoordinate = mapViewClient.getCurrentCoordinate()
            let index = input.index(input.startIndex, offsetBy: 3)
            let destination = String(input.suffix(from: index))
            self.placeSearchClient.searchPlace(destination, latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
            break
        case ConversationActions.SUMMARY.rawValue:
            let destinationInfo = AppContext.Instance.destinationInfo
            if (destinationInfo != nil) {
//                self.mapViewClient.showDestinationOnMap(
//                    mapView: self.mapView,
//                    coordinate: (destinationInfo?.geoLocation)!,
//                    annotationTitle: (destinationInfo?.name)!
//                )
                AppContext.Instance.finishedSubroutine = 0
                AppContext.Instance.reviewInsights = ""
                AppContext.Instance.walkInfo = ""
                AppContext.Instance.transitInfo = ""
                AppContext.Instance.driveInfo = ""
                //return eta (transportation method and review summary)
                self.userReviewClient.retrieveReviewInsights(placeId: (destinationInfo?.placeId)!)
                let current = self.mapViewClient.getCurrentCoordinate()
                let destination = destinationInfo?.geoLocation
                for transportType in [MKDirectionsTransportType.walking, MKDirectionsTransportType.automobile, MKDirectionsTransportType.transit] {
                    self.transportInfoClient.getTransportInfo(from: current, to: destination!, by: transportType)
                }
            }
            break
        case ConversationActions.EXIT_APP.rawValue:
            appExitClient.exitApp(response: responseText)
            break
        default:
            self.handleTextResult(result: responseText)
            break
        }
    }
    
    func handleTextResult(result: String, shouldAppendOriginalResponse : Bool = false) {
        var response = result
        if shouldAppendOriginalResponse {
            response += "\n" + AppContext.Instance.responseText
        }
        DispatchQueue.main.async {
            if (!self.textSpeechConversion.audioEngine.isRunning) {
                self.textView.text = response
                self.textSpeechConversion.textToSpeech(response)
            }
            if self.isSpeakerAccessEnabled {
                self.microphoneButton.isEnabled = true
            }
        }
    }
    
    func handlePlaceSearchResult(result : [Any]) {
        if result.count <= 0 {
            AppContext.Instance.isValidDestination = false
        } else {
            let bestMatch = result[0] as! [String : Any]
            AppContext.Instance.isValidDestination = true
            let destinationInfo = self.parseToPlaceInfo(bestMatch)
            AppContext.Instance.destinationInfo = destinationInfo

            self.mapViewClient.showDestinationOnMap(
                mapView: self.mapView,
                coordinate: destinationInfo.geoLocation,
                annotationTitle: destinationInfo.name
            )
        }
        self.startConversation()
    }
    
    func handlePlaceDetailsResult(result: GMSPlace) {
        if (result.phoneNumber == nil) {
            AppContext.Instance.hasPhoneNumber = false
            self.startConversation()
        } else {
            AppContext.Instance.hasPhoneNumber = true
            self.startConversation()
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                AppContext.Instance.isCalling = true
                self.appRedirectClient.makePhoneCall(number: result.phoneNumber!)
            }
        }
    }
    
    func handleTravelInfoResponse(response: MKETAResponse, transportType : MKDirectionsTransportType) {
        let distanceInMiles = Double(floor(100 * response.distance * 0.000621371)/100) 
        let timeInfo = self.transportInfoClient.getFormattedTime(time: response.expectedTravelTime)
        
        switch transportType {
            
        case MKDirectionsTransportType.walking:
            let walkInfo = String(distanceInMiles) + " miles ," + timeInfo
            AppContext.Instance.walkInfo = walkInfo
            break
        case MKDirectionsTransportType.transit:
            let transitInfo = timeInfo
            AppContext.Instance.transitInfo = transitInfo
            break
        case MKDirectionsTransportType.automobile:
            let driveInfo = timeInfo
            AppContext.Instance.driveInfo = driveInfo
            break
        default:
            break
        }
        AppContext.Instance.finishedSubroutine += 1
        self.handleReviewInsightsAndTransportInfo()
    }
    
    func handleUserReviewInsightsResponse(response: [String : Any]) {
        let count = response["count"] as! Int
        var responseText : String = ""
        if count != 0 {
            let positiveRate = response["positive"] as! Float
            let negativeRate = response["negative"] as! Float
            let userReviewCountInfo = "We have " + String(count) + " user reviews in total. "
            responseText = "OK! "
            if (positiveRate > 0.66) {
                responseText += "This place seems pretty good! " + userReviewCountInfo + String(positiveRate * 100) + " percent of the reviewers recommend this place!"
            } else if (negativeRate > 0.66) {
                responseText += userReviewCountInfo + "It seems like " + String(negativeRate * 100) +
                " percent of the user reviews are negative. Do you still want to go there? If you do, "
            } else if (positiveRate > 0.33 && negativeRate > 0.33) {
                responseText += userReviewCountInfo + " It seems people hold different opinions of this place. "
            } else {
                responseText += userReviewCountInfo + "Most of them are pretty neutral. "
            }
        } else {
            responseText = "There's currently no review of this place yet. "
        }
        AppContext.Instance.reviewInsights = responseText
        AppContext.Instance.finishedSubroutine += 1
        self.handleReviewInsightsAndTransportInfo()
    }
    
    func handlePostUserReviewResponse() {
        self.handleTextResult(result: "Your review has been successfully posted!", shouldAppendOriginalResponse: true)
    }
    
    
    func handleSubroutineFailure() {
        AppContext.Instance.finishedSubroutine += 1
        self.handleReviewInsightsAndTransportInfo()
    }
    
    func handleAppExitResponse(response: String) {
        DispatchQueue.main.async {
            AppContext.Instance.canStartNewConversation = true
            self.textView.text = response
            self.textSpeechConversion.textToSpeech(response)
            if self.isSpeakerAccessEnabled {
                self.microphoneButton.isEnabled = true
            }
        }
    }
    
    private func parseToPlaceInfo(_ placeInfoDict : [String : Any]) -> PlaceInfo {
        let name = placeInfoDict["name"] as! String
        let address = placeInfoDict["address"] as! String
        let placeId = placeInfoDict["place_id"] as! String
        let geoLocationDict = placeInfoDict["geo_location"] as! [String : Any]
        let latitude = geoLocationDict["lat"] as! Float
        let longitude = geoLocationDict["lng"] as! Float
        let geoLocation = GeoLocation(latitude: latitude, longitude: longitude)
        return PlaceInfo(name: name, address: address, placeId: placeId, geoLocation: geoLocation)
    }
    
    private func handleReviewInsightsAndTransportInfo() {
        if (AppContext.Instance.finishedSubroutine >= self.subroutineCount) {
            AppContext.Instance.finishedSubroutine = 0
            let context = AppContext.Instance
            var info : String = context.reviewInsights
            
            if !(context.walkInfo.isEmpty) && !(context.driveInfo.isEmpty) {
                info += "You can take a " + context.walkInfo + " walk, "
                if !(context.transitInfo.isEmpty) {
                    info += "take public transit in " + context.transitInfo + " to get there, "
                }
                info += "or request an uber ride, which roughly takes " + context.driveInfo + ". You can also call this place if you like. "
            } else {
                info += "This place seems unreachable. You can still call this place if you want. "
            }
            
            info += "What would you like me to do?"
            self.handleTextResult(result: info)
        }
    }
}

