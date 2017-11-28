//
//  ConvertLocModel.swift
//  SeeWorld
//
//  Created by Raphael on 11/15/17.
//  Copyright © 2017 Raphael. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces
import CoreData
import MapKit

class CallFuncModel {
    
    let basicModel = BaiscFuncModel()
    let addressModel = AddressModel()

    // Use to get PlaceID
    private let googleURL = "https://maps.googleapis.com/maps/api/geocode/json"
    private let googleAPIKey = "AIzaSyADePbtm8rt9GnvEC9MKahn9_fUxFm69UI"

    /**************************** CALL FUNCTION ****************************/
    // get PlaceID func, which use to get the detail about the place
    func getPlaceID(_ textView: UITextView, _ lat: String, _ lon: String) {
        
        let session = URLSession.shared
        let googleRequestURL = NSURL(string: "\(googleURL)?key=\(googleAPIKey)&latlng=\(lat),\(lon)")!
        
        
        // The data task retrieves the data.
        let dataTask = session.dataTask(with: googleRequestURL as URL) {
            (data : Data?, response : URLResponse?, error : Error?) in
            if let error = error {
                print("Error:\n\(error)")
            }
            else {
                let json = try? JSONSerialization.jsonObject(with: data!, options:  .mutableContainers) as? [String:Any]
                if let data = json!!["results"] as? [[String: Any]] {
                    for jsonDict in data {
                        let place_id = jsonDict["place_id"] as? String
                        //print(place_id!)
                        self.getPlaceDetail(textView, placeID: place_id!)
                        break
                    }
                }
            }
        }
        
        dataTask.resume()
    }
    
    
    // Get Place Detail
    func getPlaceDetail(_ textView: UITextView, placeID:String) {
        let placesClient = GMSPlacesClient()
        
        placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeID)")
                return
            }
            
            print("Place name \(place.name)")
            
            if (place.phoneNumber != nil) {
                self.makeAPhoneCall(number: place.phoneNumber!)
            }
            else {
                textView.text = "There is no phone number for your destination."
                self.basicModel.testToSpeech("There is no phone number for your destination."
                )
            }
            //print("Place openNowStatus \(place.openNowStatus)")
        })
    }
    
    // Make a Call
    func makeAPhoneCall(number: String)  {
        let url: NSURL = URL(string: "tel://1\(number)")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    
    /**************************** Google Search FUNCTION ****************************/
    
    public static func setAddress(address : String, _ textView: UITextView, _ mapView: MKMapView) -> Void {
        let fullAddr = address
        print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
        print(fullAddr)
        print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
        // Get the ETA
        let mapModel = MapModel()
        mapModel.searchPlace(textView, mapView, fullAddr: fullAddr)
    }
    
    // get PlaceID func, which use to get the detail about the place
    func googleSearch(_ textView: UITextView, _ mapView: MKMapView) {
        
        // The search place name
        var name = String(textView.text)
        name = name + "Columbus"
        
        let session = URLSession.shared
        let googleRequestURL = NSURL(string: "\(googleURL)?key=\(googleAPIKey)&address=\(name)")!
        // The data task retrieves the data.
        let dataTask = session.dataTask(with: googleRequestURL as URL) {
            (data : Data?, response : URLResponse?, error : Error?) in
            if let error = error {
                print("Error:\n\(error)")
            }
            else {
                let json = try? JSONSerialization.jsonObject(with: data!, options:  .mutableContainers) as? [String:Any]
                if let data = json!!["results"] as? [[String: Any]] {
                    for jsonDict in data {
                        let place_id = jsonDict["place_id"] as? String
                        self.getFullAddress(textView, mapView, placeID: place_id!)
                        break
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    // Get Full Address to search
    func getFullAddress(_ textView: UITextView, _ mapView: MKMapView, placeID:String) {
        
        let placesClient = GMSPlacesClient()
        placesClient.lookUpPlaceID(placeID, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(placeID)")
                return
            }
            
            
            let result = place.formattedAddress
            print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
            print(result!)
            print("^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^")
            CallFuncModel.setAddress(address: result!, textView, mapView)
        })
    }
}
